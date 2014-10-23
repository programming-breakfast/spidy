-module(collector).
-export([start/1]).

-record(state, {url_storage}).
-record(url_storage, {new = [], processing = [], error = [], complete = []}).

start(StartUrls) ->
    io:format("Collector started~n"),
    loop(#state{
      url_storage = #url_storage{new = StartUrls}
    }).

%% TODO check url for presence in any list
loop(State = #state{url_storage = UrlStorage}) ->
    receive
      {get_url, Pid} ->
        case get_url_to_process(UrlStorage) of
          {ok, Url, NewUrlStorage} ->
            Pid ! {process_url, Url},
            loop(#state{ url_storage = NewUrlStorage });
          error ->
            io:format("[no new urls] UrlStorage: ~p~n", [UrlStorage]),
            Pid ! no_url,
            loop(State)
        end;
      {done_process, Url} ->
        loop(#state{url_storage = move_url(Url, processing, complete, UrlStorage)});
      {new_url, Pid, Url} ->
        io:format("Received url ~p from crawler ~p~n", [Url, Pid]),
        loop(#state{url_storage = dict:append(new, Url, UrlStorage)});
      {status} ->
        io:format("State: ~nUrls: ~p~n", [UrlStorage]),
        loop(State);
      _ -> ok
    end.

%%private
get_url_to_process(#url_storage{new = []}) -> error;
get_url_to_process(US = #url_storage{new = [NewUrl|Rest], processing = ProcessingUrls}) ->
  {
    ok,
    NewUrl,
    US#url_storage{
      new = Rest,
      processing = ProcessingUrls ++ [NewUrl]
    }
  }.


move_url(Url, From, To, UrlStorage) ->
  OldFrom = get_value(From, UrlStorage),
  OldTo = get_value(To, UrlStorage),
  UpdatedWithFromStorage = set_value(From, erb_lists:pop(Url, OldFrom), UrlStorage),
  set_value(To, OldTo ++ [Url], UpdatedWithFromStorage).

%% get value from record
get_value(Key, Record) ->
  element(key_index(Key), Record).

set_value(Key, Value, Record) ->
  setelement(key_index(Key), Record, Value).

key_index(Key) ->
  index(Key, record_info(fields, url_storage), 2).

index(Key, [Key|_], I) -> I;
index(Key, [_|T], I) -> index(Key, T, I + 1).
