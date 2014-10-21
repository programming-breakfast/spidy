-module(collector).
-export([start/1]).

-record(state, {urls}).

start(StartUrls) ->
    io:format("Collector started~n"),
    loop(#state{
      urls = dict:store(new, StartUrls, dict:new())}
    ).

loop(State = #state{urls = UrlStorage}) ->
    receive
      {get_url, Pid} ->
        case get_url_to_process(UrlStorage) of
          {ok, Url, NewUrlStorage} ->
            Pid ! {process_url, Url},
            loop(#state{ urls = NewUrlStorage });
          error ->
            Pid ! no_url
        end;
      {done_process, _Url, _Data} ->
        loop(State);
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
