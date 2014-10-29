REBAR?=rebar

compile:
	$(REBAR) compile skip_deps=true

run: compile
	ERL_LIBS=deps erl -pa ebin -s runner run
