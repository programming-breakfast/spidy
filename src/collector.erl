-module(collector).
-export([start/1]).

-record(state, {urls}).

start(StartUrls) ->
    io:format("Collector started~n"),
    loop(#state{
      urls = dict:store(new, StartUrls, dict:new())}
    ).

%% TODO check url for presence in any list
loop(State = #state{urls = UrlStorage}) ->
    receive
      {get_url, Pid} ->
        case get_url_to_process(UrlStorage) of
          {ok, Url, NewUrlStorage} ->
            Pid ! {process_url, Url},
            loop(#state{ urls = NewUrlStorage });
          error ->
            io:format("[no new urls] UrlStorage: ~p~n", [UrlStorage]),
            Pid ! no_url,
            loop(State)
        end;
      {done_process, Url} ->
        loop(#state{urls = move_url(Url, processing, complete, UrlStorage)});
      {new_url, Pid, Url} ->
        io:format("Received url ~p from crawler ~p~n", [Url, Pid]),
        loop(#state{urls = dict:append(new, Url, UrlStorage)});
      {status} ->
        io:format("State: ~nUrls: ~p~n", [UrlStorage]),
        loop(State);
      _ -> ok
    end.

%%private
get_url_to_process(UrlStorage) ->
  case dict:find(new, UrlStorage) of
    {ok, [NewUrl|Rest]} ->
      Dict = dict:append(processing, NewUrl, dict:store(new, Rest, UrlStorage)),
      {ok, NewUrl, Dict};
    _ ->
      error
  end.

move_url(Url, From, To, UrlStorage) ->
  {ok, FromUrls} = dict:find(From, UrlStorage),
  {Url, NewFromUrls} = erb_lists:pop(Url, FromUrls),
  DictWithNewFromUrls = dict:store(From, NewFromUrls, UrlStorage),
  dict:append(To, Url, DictWithNewFromUrls).


