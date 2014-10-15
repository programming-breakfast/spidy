-module(crawler).
-export([start/2]).

start(Collector, N) ->
    io:format("Crawler ~p started with collector: ~p~n", [N, Collector]),
    Collector ! {start, self(), N},
    Collector ! {url, self(), "http://ya.ru/"},
    Collector ! {process_end, self()}.
