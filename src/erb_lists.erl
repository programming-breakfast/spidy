%%%-------------------------------------------------------------------
%%% @author timurkozmenko
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. окт 2014 10:34
%%%-------------------------------------------------------------------
-module(erb_lists).
-author("timurkozmenko").

%% API
-export([pop/2]).

pop(Element, List) ->
  pop(Element, List, [], not_found).

pop(_, [], _, not_found) -> error;
pop(_, [], Accum, _) -> Accum;
pop(Element, [Head|List], Accum, _) when Head == Element ->
  pop(Element, List, Accum, Head);
pop(Element, [Head|List], Accum, E) ->
  pop(Element, List, Accum ++ [Head], E).

