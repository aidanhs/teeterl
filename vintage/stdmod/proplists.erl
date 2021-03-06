%% ``The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved via the world wide web at http://www.erlang.org/.
%% 
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%% 
%% The Initial Developer of the Original Code is Richard Carlsson.
%% Portions created by Ericsson are Copyright 1999, Ericsson Utvecklings
%% AB. All Rights Reserved.''
%% 
%%     $Id $
%% =====================================================================
%% Support functions for property lists
%%
%% Copyright (C) 2000-2003 Richard Carlsson
%% ---------------------------------------------------------------------
%%
%% @doc Support functions for property lists.
%%
%% <p>Property lists are ordinary lists containing entries in the form
%% of either tuples, whose first elements are keys used for lookup and
%% insertion, or atoms, which work as shorthand for tuples <code>{Atom,
%% true}</code>. (Other terms are allowed in the lists, but are ignored
%% by this module.) If there is more than one entry in a list for a
%% certain key, the first occurrence normally overrides any later
%% (irrespective of the arity of the tuples).</p>
%%
%% <p>Property lists are useful for representing inherited properties,
%% such as options passed to a function where a user may specify options
%% overriding the default settings, object properties, annotations,
%% etc.</p>
%%
%% @type property() = atom() | tuple()

-module(proplists).

-export([property/1, property/2, unfold/1, compact/1, lookup/2,
	 lookup_all/2, is_defined/2, get_value/2, get_value/3,
	 get_all_values/2, append_values/2, get_bool/2, get_keys/1,
	 delete/2, substitute_aliases/2, substitute_negations/2,
	 expand/2, normalize/2, split/2]).


%% @spec property(P::property()) -> property()
%%
%% @doc Creates a normal form (minimal) representation of a property. If
%% <code>P</code> is <code>{Key, true}</code> where <code>Key</code> is
%% an atom, this returns <code>Key</code>, otherwise the whole term
%% <code>P</code> is returned.
%%
%% @see property/2

property({Key, true}) when is_atom(Key) ->
    Key;
property(Property) ->
    Property.


%% @spec property(Key::term(), Value::term()) -> property()
%%
%% @doc Creates a normal form (minimal) representation of a simple
%% key/value property. Returns <code>Key</code> if <code>Value</code> is
%% <code>true</code> and <code>Key</code> is an atom, otherwise a tuple
%% <code>{Key, Value}</code> is returned.
%%
%% @see property/1

property(Key, true) when is_atom(Key) ->
    Key;
property(Key, Value) ->
    {Key, Value}.


%% ---------------------------------------------------------------------

%% @spec unfold(List::[term()]) -> [term()]
%%
%% @doc Unfolds all occurences of atoms in <code>List</code> to tuples
%% <code>{Atom, true}</code>.
%%
%% @see compact/1

unfold([P | Ps]) ->
    if is_atom(P) ->
	    [{P, true} | unfold(Ps)];
       true ->
	    [P | unfold(Ps)]
    end;
unfold([]) ->
    [].

%% @spec compact(List::[term()]) -> [term()]
%%
%% @doc Minimizes the representation of all entries in the list. This is
%% equivalent to <code>[property(P) || P &lt;- List]</code>.
%%
%% @see unfold/1
%% @see property/1

compact(List) ->
    [property(P) || P <- List].


%% ---------------------------------------------------------------------

%% @spec lookup(Key::term(), List::[term()]) -> none | tuple()
%%
%% @doc Returns the first entry associated with <code>Key</code> in
%% <code>List</code>, if one exists, otherwise returns
%% <code>none</code>. For an atom <code>A</code> in the list, the tuple
%% <code>{A, true}</code> is the entry associated with <code>A</code>.
%%
%% @see lookup_all/2
%% @see get_value/2
%% @see get_bool/2

lookup(Key, [P | Ps]) ->
    if is_atom(P), P =:= Key ->
	    {Key, true};
       is_tuple(P), size(P) >= 1, element(1, P) =:= Key ->
	    %% Note that <code>Key</code> does not have to be an atom in this case.
	    P;
       true ->
	    lookup(Key, Ps)
    end;
lookup(_Key, []) ->
    none.

%% @spec lookup_all(Key::term(), List::[term()]) -> [tuple()]
%%
%% @doc Returns the list of all entries associated with <code>Key</code>
%% in <code>List</code>. If no such entry exists, the result is the
%% empty list.
%%
%% @see lookup/2

lookup_all(Key, [P | Ps]) ->
    if is_atom(P), P =:= Key ->
	    [{Key, true} | lookup_all(Key, Ps)];
       is_tuple(P), size(P) >= 1, element(1, P) =:= Key ->
	    [P | lookup_all(Key, Ps)];
       true ->
	    lookup_all(Key, Ps)
    end;
lookup_all(_Key, []) ->
    [].


%% ---------------------------------------------------------------------

%% @spec is_defined(Key::term(), List::[term()]) -> bool()
%%
%% @doc Returns <code>true</code> if <code>List</code> contains at least
%% one entry associated with <code>Key</code>, otherwise
%% <code>false</code> is returned.

is_defined(Key, [P | Ps]) ->
    if is_atom(P), P =:= Key ->
	    true;
       is_tuple(P), size(P) >= 1, element(1, P) =:= Key ->
	    true;
       true ->
	    is_defined(Key, Ps)
    end;
is_defined(_Key, []) ->
    false.


%% ---------------------------------------------------------------------

%% @spec get_value(Key::term(), List::[term()]) -> term()
%% @equiv get_value(Key, List, undefined)

get_value(Key, List) ->
    get_value(Key, List, undefined).

%% @spec get_value(Key::term(), List::[term()], Default::term()) ->
%%         term()
%%
%% @doc Returns the value of a simple key/value property in
%% <code>List</code>. If <code>lookup(Key, List)</code> would yield
%% <code>{Key, Value}</code>, this function returns the corresponding
%% <code>Value</code>, otherwise <code>Default</code> is returned.
%%
%% @see lookup/2
%% @see get_value/1
%% @see get_all_values/2
%% @see get_bool/2

get_value(Key, [P | Ps], Default) ->
    if is_atom(P), P =:= Key ->
	    true;
       is_tuple(P), size(P) >= 1, element(1, P) =:= Key ->
	    case P of
		{_, Value} ->
		    Value;
		_ ->
		    %% Don</code>t continue the search!
		    Default
	    end;
       true ->
	    get_value(Key, Ps, Default)
    end;
get_value(_Key, [], Default) ->
    Default.

%% @spec get_all_values(Key, List) -> [term()]
%%
%% @doc Similar to <code>get_value/2</code>, but returns the list of
%% values for <em>all</em> entries <code>{Key, Value}</code> in
%% <code>List</code>. If no such entry exists, the result is the empty
%% list.
%%
%% @see get_value/2

get_all_values(Key, [P | Ps]) ->
    if is_atom(P), P =:= Key ->
	    [true | get_all_values(Key, Ps)];
       is_tuple(P), size(P) >= 1, element(1, P) =:= Key ->
	    case P of
		{_, Value} ->
		    [Value | get_all_values(Key, Ps)];
		_ ->
		    get_all_values(Key, Ps)
	    end;
       true ->
	    get_all_values(Key, Ps)
    end;
get_all_values(_Key, []) ->
    [].

%% @spec append_values(Key::term(), List::[term()]) -> [term()]
%%
%% @doc Similar to <code>get_all_values/2</code>, but each value is
%% wrapped in a list unless it is already itself a list, and the
%% resulting list of lists is concatenated. This is often useful for
%% "incremental" options; e.g., <code>append_values(a, [{a, [1,2]}, {b,
%% 0}, {a, 3}, {c, -1}, {a, [4]}])</code> will return the list
%% <code>[1,2,3,4]</code>.
%%
%% @see get_all_values/2

append_values(Key, [P | Ps]) ->
    if is_atom(P), P =:= Key ->
	    [true | append_values(Key, Ps)];
       is_tuple(P), size(P) >= 1, element(1, P) =:= Key ->
	    case P of
		{_, Value} when is_list(Value) ->
		    Value ++ append_values(Key, Ps);
		{_, Value} ->
		    [Value | append_values(Key, Ps)];
		_ ->
		    append_values(Key, Ps)
	    end;
       true ->
	    append_values(Key, Ps)
    end;
append_values(_Key, []) ->
    [].


%% ---------------------------------------------------------------------

%% @spec get_bool(Key::term(), List::[term()]) -> bool()
%%
%% @doc Returns the value of a boolean key/value option. If
%% <code>lookup(Key, List)</code> would yield <code>{Key, true}</code>,
%% this function returns <code>true</code>; otherwise <code>false</code>
%% is returned.
%%
%% @see lookup/2
%% @see get_value/2

get_bool(Key, [P | Ps]) ->
    if is_atom(P), P =:= Key ->
	    true;
       is_tuple(P), size(P) >= 1, element(1, P) =:= Key ->
	    case P of
		{_, true} ->
		    true;
		_ ->
		    %% Don't continue the search!
		    false
	    end;
       true ->
	    get_bool(Key, Ps)
    end;
get_bool(_Key, []) ->
    false.


%% ---------------------------------------------------------------------

%% @spec get_keys(List::term()) -> [term()]
%%
%% @doc Returns an unordered list of the keys used in <code>List</code>,
%% not containing duplicates.

get_keys(Ps) ->
    sets:to_list(get_keys(Ps, sets:new())).

get_keys([P | Ps], Keys) ->
    if is_atom(P) ->
	    get_keys(Ps, sets:add_element(P, Keys));
       is_tuple(P), size(P) >= 1 ->
	    get_keys(Ps, sets:add_element(element(1, P), Keys));
       true ->
	    get_keys(Ps, Keys)
    end;
get_keys([], Keys) ->
    Keys.


%% ---------------------------------------------------------------------

%% @spec delete(Key::term(), List::[term()]) -> [term()]
%%
%%
%% @doc Deletes all entries associated with <code>Key</code> from
%% <code>List</code>.

delete(Key, [P | Ps]) ->
    if is_atom(P), P =:= Key ->
	    delete(Key, Ps);
       is_tuple(P), size(P) >= 1, element(1, P) =:= Key ->
	    delete(Key, Ps);
       true ->
	    [P | delete(Key, Ps)]
    end;
delete(_, []) ->
    [].


%% ---------------------------------------------------------------------

%% @spec substitute_aliases(Aliases, List::[term()]) -> [term()]
%%
%%	    Aliases = [{Key, Key}]
%%	    Key = term()
%%
%% @doc Substitutes keys of properties. For each entry in
%% <code>List</code>, if it is associated with some key <code>K1</code>
%% such that <code>{K1, K2}</code> occurs in <code>Aliases</code>, the
%% key of the entry is changed to <code>Key2</code>. If the same
%% <code>K1</code> occurs more than once in <code>Aliases</code>, only
%% the first occurrence is used.
%%
%% <p>Example: <code>substitute_aliases([{color, colour}], L)</code>
%% will replace all tuples <code>{color, ...}</code> in <code>L</code>
%% with <code>{colour, ...}</code>, and all atoms <code>color</code>
%% with <code>colour</code>.</p>
%%
%% @see substitute_negations/2
%% @see normalize/2

substitute_aliases(As, Props) ->
    [substitute_aliases_1(As, P) || P <- Props].

substitute_aliases_1([{Key, Key1} | As], P) ->
    if is_atom(P), P =:= Key ->
	    property(Key1, true);
       is_tuple(P), size(P) >= 1, element(1, P) =:= Key ->
	    property(setelement(1, P, Key1));
       true ->
	    substitute_aliases_1(As, P)
    end;
substitute_aliases_1([], P) ->
    P.


%% ---------------------------------------------------------------------

%% @spec substitute_negations(Negations, List::[term()]) -> [term()]
%%
%%	    Negations = [{Key, Key}]
%%	    Key = term()
%%
%% @doc Substitutes keys of boolean-valued properties and simultaneously
%% negates their values. For each entry in <code>List</code>, if it is
%% associated with some key <code>K1</code> such that <code>{K1,
%% K2}</code> occurs in <code>Negations</code>, then if the entry was
%% <code>{K1, true}</code> it will be replaced with <code>{K2,
%% false}</code>, otherwise it will be replaced with <code>{K2,
%% true}</code>, thus changing the name of the option and simultaneously
%% negating the value given by <code>get_bool(List)</code>. If the same
%% <code>K1</code> occurs more than once in <code>Negations</code>, only
%% the first occurrence is used.
%%
%% <p>Example: <code>substitute_negations([{no_foo, foo}], L)</code>
%% will replace any atom <code>no_foo</code> or tuple <code>{no_foo,
%% true}</code> in <code>L</code> with <code>{foo, false}</code>, and
%% any other tuple <code>{no_foo, ...}</code> with <code>{foo,
%% true}</code>.</p>
%%
%% @see get_bool/2
%% @see substitute_aliases/2
%% @see normalize/2

substitute_negations(As, Props) ->
    [substitute_negations_1(As, P) || P <- Props].

substitute_negations_1([{Key, Key1} | As], P) ->
    if is_atom(P), P =:= Key ->
	    property(Key1, false);
       is_tuple(P), size(P) >= 1, element(1, P) =:= Key ->
	    case P of
		{_, true} ->
		    property(Key1, false);
		{_, false} ->
		    property(Key1, true);
		_ ->
		    %% The property is supposed to be a boolean, so any
		    %% other tuple is interpreted as `false', as done in
		    %% `get_bool'.
		    property(Key1, true)
	    end;		    
       true ->
	    substitute_negations_1(As, P)
    end;
substitute_negations_1([], P) ->
    P.


%% ---------------------------------------------------------------------

%% @spec expand(Expansions, List::[term()]) -> [term()]
%%
%%	    Expansions = [{property(), [term()]}]
%%
%% @doc Expands particular properties to corresponding sets of
%% properties (or other terms). For each pair <code>{Property,
%% Expansion}</code> in <code>Expansions</code>, if <code>E</code> is
%% the first entry in <code>List</code> with the same key as
%% <code>Property</code>, and <code>E</code> and <code>Property</code>
%% have equivalent normal forms, then <code>E</code> is replaced with
%% the terms in <code>Expansion</code>, and any following entries with
%% the same key are deleted from <code>List</code>.
%%
%% <p>For example, the following expressions all return <code>[fie, bar,
%% baz, fum]</code>:
%% <ul>
%%   <li><code>expand([{foo, [bar, baz]}],
%%                    [fie, foo, fum])</code></li>
%%   <li><code>expand([{{foo, true}, [bar, baz]}],
%%                    [fie, foo, fum])</code></li>
%%   <li><code>expand([{{foo, false}, [bar, baz]}],
%%                    [fie, {foo, false}, fum])</code></li>
%% </ul>
%% However, no expansion is done in the following call:
%% <ul>
%%   <li><code>expand([{{foo, true}, [bar, baz]}],
%%                    [{foo, false}, fie, foo, fum])</code></li>
%% </ul>
%% because <code>{foo, false}</code> shadows <code>foo</code>.</p>
%%
%% <p>Note that if the original property term is to be preserved in the
%% result when expanded, it must be included in the expansion list. The
%% inserted terms are not expanded recursively. If
%% <code>Expansions</code> contains more than one property with the same
%% key, only the first occurrance is used.</p>
%%
%% @see normalize/2

expand(Es, Ps) when is_list(Ps) ->
    Es1 = [{property(P), V} || {P, V} <- Es],
    flatten(expand_0(key_uniq(Es1), Ps)).

%% Here, all key properties are normalized and there are no multiple
%% entries in the list of expansions for any specific key property. We
%% insert the expansions one at a time - this is quadratic, but gives
%% the desired behaviour in a simple way.

expand_0([{P, L} | Es], Ps) ->
    expand_0(Es, expand_1(P, L, Ps));
expand_0([], Ps) ->
    Ps.

expand_1(P, L, Ps) ->
    %% First, we must find out what key to look for.
    %% P has a minimal representation here.
    if is_atom(P) ->
	    expand_2(P, P, L, Ps);
       is_tuple(P), size(P) >= 1 ->
	    expand_2(element(1, P), P, L, Ps);
       true ->
	    Ps    % refuse to expand non-property
    end.

expand_2(Key, P1, L, [P | Ps]) ->
    if is_atom(P), P =:= Key ->
	    expand_3(Key, P1, P, L, Ps);
       is_tuple(P), size(P) >= 1, element(1, P) =:= Key ->
	    expand_3(Key, P1, property(P), L, Ps);
       true ->
	    %% This case handles non-property entries, and thus
	    %% any already inserted expansions (lists), by simply
	    %% ignoring them.
	    [P | expand_2(Key, P1, L, Ps)]
    end;
expand_2(_, _, _, []) ->
    [].

expand_3(Key, P1, P, L, Ps) ->
    %% Here, we have found the first entry with a matching key. Both P
    %% and P1 have minimal representations here. The inserted list will
    %% be flattened afterwards. If the expansion is done, we drop the
    %% found entry and alao delete any later entries with the same key.
    if P1 =:= P ->
	    [L | delete(Key, Ps)];
       true ->
	    %% The existing entry does not match - keep it.
	    [P | Ps]
    end.

key_uniq([{K, V} | Ps]) ->
    [{K, V} | key_uniq_1(K, Ps)];
key_uniq([]) ->
    [].

key_uniq_1(K, [{K1, V} | Ps]) ->
    if K =:= K1 ->
	    key_uniq_1(K, Ps);
       true ->
	    [{K1, V} | key_uniq_1(K1, Ps)]
    end;
key_uniq_1(_, []) ->
    [].

%% This does top-level flattening only.

flatten([E | Es]) when is_list(E) ->
    E ++ flatten(Es);
flatten([E | Es]) ->
    [E | flatten(Es)];
flatten([]) ->
    [].


%% ---------------------------------------------------------------------

%% @spec normalize(List::[term()], Stages::[Operation]) -> [term()]
%%
%%	    Operation = {aliases, Aliases} | {negations, Negations}
%%                    | {expand, Expansions}
%%	    Aliases = [{Key, Key}]
%%	    Negations = [{Key, Key}]
%%	    Key = term()
%%	    Expansions = [{property(), [term()]}]
%%
%% @doc Passes <code>List</code> through a sequence of
%% substitution/expansion stages. For an <code>aliases</code> operation,
%% the function <code>substitute_aliases/2</code> is applied using the
%% given list of aliases; for a <code>negations</code> operation,
%% <code>substitute_negations/2</code> is applied using the given
%% negation list; for an <code>expand</code> operation, the function
%% <code>expand/2</code> is applied using the given list of expansions.
%% The final result is automatically compacted (cf.
%% <code>compact/1</code>).
%%
%% <p>Typically you want to substitute negations first, then aliases,
%% then perform one or more expansions (sometimes you want to pre-expand
%% particular entries before doing the main expansion). You might want
%% to substitute negations and/or aliases repeatedly, to allow such
%% forms in the right-hand side of aliases and expansion lists.</p>
%%
%% @see substitute_aliases/2
%% @see substitute_negations/2
%% @see expand/2
%% @see compact/1

normalize(L, [{aliases, As} | Xs]) ->
    normalize(substitute_aliases(As, L), Xs);
normalize(L, [{expand, Es} | Xs]) ->
    normalize(expand(Es, L), Xs);
normalize(L, [{negations, Ns} | Xs]) ->
    normalize(substitute_negations(Ns, L), Xs);
normalize(L, []) ->
    compact(L).

%% ---------------------------------------------------------------------

%% @spec split(List::[term()], Keys::[term()]) -> {Lists, Rest}
%%           Lists = [[term()]]
%%           Rest = [term()]
%%
%% @doc Partitions <code>List</code> into a list of sublists and a
%% remainder. <code>Lists</code> contains one sublist for each key in
%% <code>Keys</code>, in the corresponding order. The relative order of
%% the elements in each sublist is preserved from the original
%% <code>List</code>. <code>Rest</code> contains the elements in
%% <code>List</code> that are not associated with any of the given keys,
%% also with their original relative order preserved.
%%
%% <p>Example:<pre>
%% split([{c, 2}, {e, 1}, a, {c, 3, 4}, d, {b, 5}, b], [a, b, c])</pre>
%% returns<pre>
%% {[[a], [{b, 5}, b],[{c, 2}, {c, 3, 4}]], [{e, 1}, d]}</pre>
%% </p>

split(List, Keys) ->
    {Store, Rest} = split(List, dict:from_list([{K, []} || K <- Keys]), []),
    {[lists:reverse(dict:fetch(K, Store)) || K <- Keys],
     lists:reverse(Rest)}.

split([P | Ps], Store, Rest) ->
    if is_atom(P) ->
	    case dict:is_key(P, Store) of
		true ->
		    split(Ps, dict_prepend(P, P, Store), Rest);
		false ->
		    split(Ps, Store, [P | Rest])
	    end;
       is_tuple(P), size(P) >= 1 ->
	    %% Note that Key does not have to be an atom in this case.
	    Key = element(1, P),
	    case dict:is_key(Key, Store) of
		true ->
		    split(Ps, dict_prepend(Key, P, Store), Rest);
		false ->
		    split(Ps, Store, [P | Rest])
	    end;
       true ->
	    split(Ps, Store, [P | Rest])
    end;
split([], Store, Rest) ->
    {Store, Rest}.

dict_prepend(Key, Val, Dict) ->
    dict:store(Key, [Val | dict:fetch(Key, Dict)], Dict).
