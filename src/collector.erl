-module(collector).
-export([start/0]).

start() ->
    io:format("Collector started~n"),
    loop().

loop() ->
    receive
        Msg ->
            io:format(Msg)
    end,
    loop().
