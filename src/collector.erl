-module(collector).
-export([start/1]).

-record(state, {pids, urls}).

start(Urls) ->
    io:format("Collector started~n"),
    loop(#state{
      pids = dict:new(),
      urls = dict:store(new, sets:from_list(Urls), dict:new())}
    ).

loop(#state{pids = Pids, urls = Urls}) ->
    receive
        {start, Pid, N} ->
            io:format("Crawler #~p started with pid ~p~n", [N, Pid]),
            loop(#state{pids = dict:store(Pid, N, Pids), urls = Urls});
        {post_url, Pid, Url} ->
            io:format("Received url ~p from crawler ~p~n", [Url, dict:fetch(Pid, Pids)]),
            loop(#state{pids = Pids, urls = erb_dict:append_to_set(new, Url, Urls)});
        {process_end, Pid} ->
            io:format("Crawler died ~p~n", [Pid]),
            loop(#state{pids = dict:erase(Pid, Pids), urls = Urls})
    end.

%%private
