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
      process_url(Url, Collector),
      loop(Collector);
    no_url ->
      timer:sleep(?SLEEP_TIME),
      loop(Collector);
    _ -> loop(Collector)
  end.

process_url(Url, Collector) ->
  Method = get,
  Headers = [],
  Payload = <<>>,
  Options = [],
  case hackney:request(Method, Url, Headers, Payload, Options) of
    {ok, 200, _RespHeaders, ClientRef} ->
      {ok, Body} = hackney:body(ClientRef),
      parse_server:process(Body);
    {ok, StatusCode, _RespHeaders, _ClientRef} ->
      io:format("~p got ~p while processing ~p", [?MODULE, StatusCode, Url]),
      Collector ! {error_process, Url};
    {error, _Reason} ->
      io:format("~p got unknown error", [?MODULE]),
      Collector ! {error_process, Url}
  end.
