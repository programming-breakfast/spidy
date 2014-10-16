-module(erb_sets).
-export([pop/1]).

pop(Set) ->
  Element = hd(sets:to_list(Set)),
  NewSet = sets:del_element(Element, Set),
  {Element, NewSet}.

