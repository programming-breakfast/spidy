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
      case parser:parse(Body) of
        ok -> Collector ! {done_process, Url};
        error -> Collector ! {error_process, Url}
      end;
    {ok, StatusCode, _RespHeaders, _ClientRef} ->
      {error, "Unexpected status code " ++ integer_to_list(StatusCode)},
      Collector ! {error_process, Url};
    {error, Reason} ->
      Collector ! {error_process, Url}
  end.
