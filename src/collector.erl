-module(collector).
-export([start/1]).

-record(state, {urls}).

start(StartUrls) ->
    io:format("Collector started~n"),
    loop(#state{
      urls = dict:store(new, StartUrls, dict:new())}
    ).

loop(State = #state{urls = Urls}) ->
    receive
        {get_url, Pid} ->
          case get_url_to_process(Urls) of
            {ok, Url, NewUrls} ->
		  Pid ! {process_url, Url},
		  loop(#state{ urls = NewUrls });
	    error ->
		  Pid ! no_url
          end;
	{done_process, _Url, _Data} ->
	    loop(State); 
        {new_url, Pid, Url} ->
            io:format("Received url ~p from crawler ~p~n", [Url, Pid]),
            loop(#state{urls = dict:append(new, Url, Urls)});
        {status} ->
            io:format("State: ~nUrls: ~p~n", [Urls]),
            loop(State);
	_ -> ok
    end.

%%private
get_url_to_process(Urls) ->
  case dict:find(new, Urls) of
      {ok, [NewUrl|Rest]} -> 
	Dict = dict:append(processing, NewUrl, dict:store(new, Rest, Urls)),
	{ok, NewUrl, Dict};
      _ ->
	error
  end.
