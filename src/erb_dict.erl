-module(erb_dict).
-export([append_to_set/3, remove_from_set/3, pop_from_set/2]).

append_to_set(Key, Value, Dict) ->
  Set = dict:fetch(Key, Dict),
  NewSet = sets:add_element(Value, Set),
  dict:store(Key, NewSet, Dict).

remove_from_set(Key, Value, Dict) ->
  Set = dict:fetch(Key, Dict),
  NewSet = sets:del_element(Value, Set),
  dict:store(Key, NewSet, Dict).

pop_from_set(Key, Dict) ->
  Set = dict:fetch(Key, Dict),
  {Element, NewSet} = erb_sets:pop(Set),
  {Element, dict:store(Key, NewSet, Dict)}.

