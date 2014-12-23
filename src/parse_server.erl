-module(parse_server).
-behaviour(gen_server).

-export([
  init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3
]).
-export([start_link/0, stop/0, process/1, get_html/0]).

%%
%% API
%%

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
  gen_server:call(?MODULE, stop).

process(HtmlToProcess) -> gen_server:cast(?MODULE, {process, HtmlToProcess}).

get_html() -> gen_server:call(?MODULE, get_html).

init([]) ->
    %% Note we must set trap_exit = true if we
    %% want terminate/2 to be called when the application
    %% is stopped
    %% NOTE: We do not completely understand the background of the following line.
    %% Should try uncommenting it when we move to starting the server by supervisor
    %% process_flag(trap_exit, true),
    io:format("~p starting~n", [?MODULE]),
    {ok, []}.

handle_info(Info, State) ->
    io:format("~p got unknown info message ~p~n", [?MODULE, Info]),
    {noreply, State}.

terminate(Reason, _State) ->
    io:format("~p stopping for reason: ~p~n", [?MODULE, Reason]),
    ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

%%
%% APP
%%

handle_cast({process, HtmlToProcess}, State) -> {noreply, State ++ [HtmlToProcess]}.

handle_call(get_html, _From, [HtmlToProcess | State]) -> {reply, HtmlToProcess, State}.

