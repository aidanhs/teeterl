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
%% The Initial Developer of the Original Code is Ericsson Utvecklings AB.
%% Portions created by Ericsson are Copyright 1999, Ericsson Utvecklings
%% AB. All Rights Reserved.''
%% 
%%     $Id$
%%

%% Generic compiler options, passed from the erl_compile module.

-record(options,
	 {includes=[] :: [string()],		% Include paths (list of
						% absolute directory names).
	  outdir="."  :: string(),		% Directory for result
						% (absolute path).
	  output_type=undefined :: atom(),	% Type of output file.
	  defines=[], %% ***MK***  :: [atom() | {atom(),_}],	% Preprocessor defines.  Each
						% element is an atom
						% (the name to define), or 
						% a {Name, Value} tuple.
	  warning=1   :: non_neg_integer(),	% Warning level (0 - no
						% warnings, 1 - standard level,
						% 2, 3, ... - more warnings).
	  verbose=false :: bool(),		% Verbose (true/false).
	  optimize=999,				% Optimize options.
	  specific=[], %% ***MK*** :: [_],			% Compiler specific options.
	  outfile=""  :: string(),		% Name of output file (internal
						% use in erl_compile.erl).
	  cwd	      :: string()		% Current working directory
						% for erlc.
	 }).

