-module(environment_patterns).
-export([main/0, evaluate/1]).

evaluate([]) -> {error, missing};
evaluate([Text | _]) ->
    case Text =/= [] andalso lists:all(fun(C) -> C >= $0 andalso C =< $9 end, Text) of
        false -> {error, invalid};
        true ->
            Value = list_to_integer(Text),
            case Value of
                N when N > 255 -> {error, invalid};
                N when N > 248 -> {error, overflow};
                N -> {ok, N + 7}
            end
    end.

main() ->
    case evaluate(init:get_plain_arguments()) of
        {ok, Value} -> io:format("ok:~B~n", [Value]);
        {error, Reason} -> io:format("err:~s~n", [atom_to_list(Reason)])
    end,
    halt(0).
