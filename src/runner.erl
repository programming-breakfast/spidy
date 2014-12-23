-module(runner).
-export([run/0]).

-define(CRAWLERS_COUNT, 3).

run() ->
    io:format("Spidy starting~n"),
    hackney:start(),
    io:format("~p~n", [parse_server:start_link()]),
    Collector = spawn(collector, start, [
    %% Get some real persistant storage here
      [<<"http://globalgroovers.blogspot.com">>]
    ]),
    start_crawlers(Collector),
    io:format("Spidy started~n").

%% private
start_crawlers(Collector) -> start_crawlers(1, Collector).
start_crawlers(N, _) when N >= ?CRAWLERS_COUNT -> ok;
start_crawlers(N, Collector) ->
    spawn(crawler, start, [Collector]),
    start_crawlers(N + 1, Collector).
