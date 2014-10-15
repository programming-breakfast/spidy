-module(collector).
-export([start/0]).

start() ->
    io:format("Collector started~n"),
    loop(dict:new()).

loop(Pids) ->
    receive
        {start, Pid, N} ->
            io:format("Crawler #~p started with pid ~p~n", [N, Pid]),
            loop(dict:store(Pid, N, Pids));
        {url, Pid, Url} ->
            io:format("Received url ~p from crawler ~p~n", [Url, dict:fetch(Pid, Pids)]),
            loop(Pids);
        {process_end, Pid} ->
            io:format("Crawler died ~p~n", [Pid]),
            loop(dict:erase(Pid, Pids))
    end.
