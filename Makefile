REBAR?=rebar

compile:
        $(REBAR) compile skip_deps=true

run: compile
	erl -pa ebin -s runner run
