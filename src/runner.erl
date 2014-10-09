-module(runner).
-export([run/0]).

-define(CRAWLERS_COUNT, 5).

run() ->
    io:format("Spidy starting~n"),
    Collector = spawn(collector, start, []),
    start_crawlers(?CRAWLERS_COUNT, Collector),
    io:format("Spidy started~n").

start_crawlers(0, _) -> ok;
start_crawlers(N, Collector) ->
    spawn(crawler, start, [Collector, N]),
    start_crawlers(N - 1, Collector).

