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
      {ok, Body} = process_url(Url),
      io:format("Parsed page: ~ts~n", [unicode:characters_to_list(Body, utf8)]),
      io:format("~p~n", [mochiweb_html:tokens(Body)]),
      Collector ! {done_process, Url},
      loop(Collector);
    no_url ->
      timer:sleep(?SLEEP_TIME),
      loop(Collector);
    _ -> loop(Collector)
  end.

process_url(Url) ->
  Method = get,
  Headers = [],
  Payload = <<>>,
  Options = [],
  case hackney:request(Method, Url, Headers, Payload, Options) of
    {ok, 200, _RespHeaders, ClientRef} ->
      {ok, _Body} = hackney:body(ClientRef);
    {ok, StatusCode, _RespHeaders, _ClientRef} ->
      {error, "Unexpected status code " ++ integer_to_list(StatusCode)};
    {error, Reason} ->
      {error, Reason}
  end.
