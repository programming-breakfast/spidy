-module(runner).
-export([run/0]).

-define(CRAWLERS_COUNT, 3).

run() ->
    io:format("Spidy starting~n"),
    Collector = spawn(collector, start, [
      ["http://ya.ru", "http://google.ru", "http://test.ru"]
    ]),
    start_crawlers(Collector),
    io:format("Spidy started~n").

%% private
start_crawlers(Collector) -> start_crawlers(1, Collector).
start_crawlers(N, _) when N >= ?CRAWLERS_COUNT -> ok;
start_crawlers(N, Collector) ->
    spawn(crawler, start, [Collector]),
    start_crawlers(N + 1, Collector).
