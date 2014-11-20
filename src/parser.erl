-module(parser).

-export([parse/1]).

-record(article, {title}).

parse(Body) ->
  SaxTree = mochiweb_html:tokens(Body),
  lists:foldl(fun(Element, Accum) ->
    case Element of
      {start_tag, <<"h3">>, Attributes, _} -> ok;
      {end_tag, <<"h3">>} -> ok
    end
  end, [], SaxTree),
  ok.
