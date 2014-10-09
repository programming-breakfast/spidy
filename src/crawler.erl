-module(crawler).
-export([start/2]).

start(Collector, N) ->
    io:format("Crawler ~p started with collector: ~p~n", [N, Collector]),
    Collector ! "Privet drug from crawler #" ++ [N] ++ "~n".
