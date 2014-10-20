-module(crawler).
-export([start/1]).

-define(SLEEP_TIME, 1000).

start(Collector) ->
  io:format("Crawler started with collector: ~p~n", [Collector]),
  loop(Collector).

%% PRIVATE

loop(Collector) ->
  Collector ! {get_url, self()},
  receive
    {process_url, Url} ->
      io:format("Receive new url: ~p~n", [Url]),
      Data = process_url(Url),
      Collector ! {done_process, Url, Data},
      loop(Collector);
    no_url -> 
      timer:sleep(?SLEEP_TIME),
      loop(Collector);
    _ -> loop(Collector)
  end.

process_url(_Url) -> ok.
