#!/usr/bin/env bash
# A Script that automates pasting to a number of pastebin services
# relying only on bash, sed, coreutils (mktemp/sort/tr/wc/whoami/tee) and wget
# Copyright (c) 2007-2016 Bo Ørsted Andresen <bo.andresen@zlin.dk>
# Distributed in the public domain. Do with it whatever you want.

VERSION="2.28"

# don't inherit LANGUAGE from the env
unset LANGUAGE

# escape and new line characters
E=$'\e'
N=$'\n'

### services
SERVICES="codepad bpaste dpaste gists poundpython"
# bpaste
ENGINE_bpaste=pinnwand
URL_bpaste="https://bpaste.net/"
DEFAULT_EXPIRATION_bpaste="1week"
DEFAULT_LANGUAGE_bpaste="text"
# codepad
ENGINE_codepad=codepad
URL_codepad="http://codepad.org/"
SIZE_codepad="64000 64%KB"
# dpaste
ENGINE_dpaste=dpaste
URL_dpaste="http://dpaste.com/"
SIZE_dpaste="25000 25%kB"
DESCRIPTION_SIZE_dpaste="50"
DEFAULT_EXPIRATION_dpaste="30 days"
# gists
ENGINE_gists=gists
URL_gists="https://api.github.com/gists"
# poundpython
ENGINE_poundpython=lodgeit
URL_poundpython="https://paste.pound-python.org/"
# tinyurl
ENGINE_tinyurl=tinyurl
URL_tinyurl="http://tinyurl.com/ api-create.php"
REGEX_RAW_tinyurl='s|^\(http://[^/]*/\)\([[:alnum:]]*\)$|\1\2|'

### engines
# codepad
LANGUAGES_codepad="C C++ D Haskell Lua OCaml PHP Perl Plain%Text Python Ruby Scheme Tcl"
POST_codepad="submit % % lang % % code"
REGEX_URL_codepad='s|^--.*\(http://codepad.org/[^ ]\+\)|\1|p'
REGEX_RAW_codepad='s|^\(http://[^/]*/\)\([[:alnum:]]*\)$|\1\2/raw.rb|'
# dpaste
LANGUAGES_dpaste="Plain%Text Apache%Config Bash CSS Diff Django%Template/HTML Haskell JavaScript \
Python Python%Interactive/Traceback Ruby Ruby%HTML%(ERB) SQL XML"
LANGUAGE_VALUES_dpaste="% Apache Bash Css Diff DjangoTemplate Haskell JScript Python PythonConsole \
Ruby Rhtml Sql Xml"
EXPIRATIONS_dpaste="30%days 30%days%after%last%view"
EXPIRATION_VALUES_dpaste="off on"
POST_dpaste="submit=Paste+it poster title language hold % content"
REGEX_RAW_dpaste='s|^\(http://[^/]*/\)[^0-9]*\([0-9]*/\)$|\1\2plain/|'
# gists
LANGUAGES_gists="ActionScript Ada Apex AppleScript Arc Arduino ASP Assembly
Augeas AutoHotkey Batchfile Befunge BlitzMax Boo Brainfuck Bro C C# C++
C2hs%Haskell ChucK Clojure CMake C-ObjDump CoffeeScript ColdFusion Common%Lisp
Coq Cpp-ObjDump CSS Cucumber Cython D Darcs%Patch Dart DCPU-16%ASM Delphi Diff
D-ObjDump Dylan eC Ecere%Projects Eiffel Elixir Emacs%Lisp Erlang F# Factor
Fancy Fantom FORTRAN GAS Genshi Gentoo%Ebuild Gentoo%Eclass Gettext%Catalog Go
Gosu Groff Groovy Groovy%Server%Pages Haml Haskell HaXe HTML HTML+Django
HTML+ERB HTML+PHP INI Io Ioke IRC%log Java JavaScript Java%Server%Pages JSON
Julia Kotlin LilyPond Literate%Haskell LLVM Logtalk Lua Makefile Mako Markdown
Matlab Max/MSP MiniD Mirah Moocode mupad Myghty Nemerle Nimrod Nu NumPy ObjDump
Objective-C Objective-J OCaml ooc Opa OpenCL OpenEdge%ABL Parrot Parrot%Assembly
Parrot%Internal%Representation Perl PHP Plain%Text PowerShell Prolog Puppet
Pure%Data Python Python%traceback R Racket Raw%token%data Rebol Redcode
reStructuredText RHTML Ruby Rust Sage Sass Scala Scheme Scilab SCSS Self Shell
Smalltalk Smarty SQL Standard%ML SuperCollider Tcl Tcsh Tea TeX Textile Turing
Twig Vala Verilog VHDL VimL Visual%Basic XML XQuery XS YAML Auto"
LANGUAGE_VALUES_gists="as adb cls scpt arc ino asp asm aug ahk bat befunge bmx
boo b bro c cs cpp chs ck clj cmake c-objdump coffee cfm lisp v cppobjdump css
feature pyx d darcspatch dart dasm16 pas diff d-objdump dylan ec epj e ex el erl
fs factor fy fan f90 s kid ebuild eclass po go gs man groovy gsp haml hs hx html
mustache erb phtml cfg io ik weechatlog java js jsp json jl kt ly lhs ll lgt lua
mak mako md matlab mxt minid duby moo mu myt n nim nu numpy objdump m j ml ooc
opa cl p parrot pasm pir pl aw txt ps1 pl pp pd py pytb r rkt raw r cw rst rhtml
rb rs sage sass scala scm sci scss self sh st tpl sql sml sc tcl tcsh tea tex
textile t twig vala v vhd vim vb xml xq xs yml auto"
DEFAULT_LANGUAGE_gists="Auto"
REGEX_URL_gists='s|^.*"html_url": "\([^"]\+gist[^"]\+\)".*$|\1|p'
REGEX_RAW_gists='s|^\(https://gist.github.com\)\(/.*\)$|\1/raw\2|'
escape_description_gists() { sed -e 's|"|\\"|g' -e 's|\x1b|\\u001b|g' -e 's|\r||g' <<< "$*"; }
escape_input_gists() { sed -e 's|\\|\\\\|g' -e 's|\x1b|\\u001b|g' -e 's|\r||g' -e 's|\t|\\t|g' -e 's|"|\\"|g' -e 's|$|\\n|' <<< "$*" | tr -d '\n'; }
json_gists() {
    local description="${1}" language="${2}" content="${3}"
    [[ "$language" = auto ]] && language="" || language=".$language"
    echo "{\"description\":\"${description}\",\"public\":\"${PUBLIC_gists}\",\"files\":{\"${description//\/}${language}\":{\"content\":\"${content}\"}}"
}
# lodgeit
LANGUAGES_lodgeit="ABAP ActionScript ActionScript%3 Ada ANTLR ANTLR%With%ActionScript%Target \
ANTLR%With%CPP%Target ANTLR%With%C#%Target ANTLR%With%Java%Target ANTLR%With%ObjectiveC%Target \
ANTLR%With%Perl%Target ANTLR%With%Python%Target ANTLR%With%Ruby%Target ApacheConf AppleScript \
aspx-cs aspx-vb Asymptote Bash Bash%Session Batchfile BBCode Befunge Boo Brainfuck C C# C++ \
cfstatement Cheetah Clojure CMake c-objdump CoffeeScript Common%Lisp cpp-objdump Creole%Wiki CSS \
CSS+Django/Jinja CSS+Genshi%Text CSS+Mako CSS+Myghty CSS+PHP CSS+Ruby CSS+Smarty CSV Cython D \
Darcs%Patch Debian%Control%file Debian%Sourcelist Delphi Django/Jinja d-objdump Dylan Embedded%Ragel \
ERB Erlang Erlang%erl%session Evoque Felix Fortran GAS GCC%Messages Genshi Genshi%Text \
Gettext%Catalog Gherkin GLSL Gnuplot Go Groff Haml Haskell haXe HTML HTML+Cheetah HTML+Django/Jinja \
HTML+Evoque HTML+Genshi HTML+Mako HTML+Myghty HTML+PHP HTML+Smarty INI Io IRC%logs Java \
javac%Messages JavaScript JavaScript+Cheetah JavaScript+Django/Jinja JavaScript+Genshi%Text \
JavaScript+Mako JavaScript+Myghty JavaScript+PHP JavaScript+Ruby JavaScript+Smarty Java%Server%Page \
Lighttpd%configuration%file Literate%Haskell LLVM Logtalk Lua Makefile Mako Matlab Matlab%session \
MiniD Modelica Modula-2 MoinMoin/Trac%Wiki%markup MOOCode Multi-File MuPAD MXML Myghty MySQL NASM \
Newspeak Nginx%configuration%file NumPy objdump Objective-C Objective-J OCaml Ooc Perl PHP \
Plain%Text POVRay Prolog Python Python%3 Python%3.0%Traceback Python%console%session \
Python%Traceback Ragel Ragel%in%C%Host Ragel%in%CPP%Host Ragel%in%D%Host Ragel%in%Java%Host \
Ragel%in%Objective%C%Host Ragel%in%Ruby%Host Raw%token%data RConsole REBOL Redcode reStructuredText \
RHTML Ruby Ruby%irb%session S Sass Scala Scheme Smalltalk Smarty SQL sqlite3con SquidConf Tcl Tcsh \
TeX Unified%Diff Vala VB.net VimL XML XML+Cheetah XML+Django/Jinja XML+Evoque XML+Mako XML+Myghty \
XML+PHP XML+Ruby XML+Smarty XSLT YAML"
LANGUAGE_VALUES_lodgeit="abap as as3 ada antlr antlr-as antlr-cpp antlr-csharp antlr-java antlr-objc \
antlr-perl antlr-python antlr-ruby apacheconf applescript aspx-cs aspx-vb asy bash console bat \
bbcode befunge boo brainfuck c csharp cpp cfs cheetah clojure cmake c-objdump coffee-script \
common-lisp cpp-objdump creole css css+django css+genshitext css+mako css+myghty css+php css+erb \
css+smarty csv cython d dpatch control sourceslist delphi django d-objdump dylan ragel-em erb erlang \
erl evoque felix fortran gas gcc-messages genshi genshitext pot Cucumber glsl gnuplot go groff haml \
haskell hx html html+cheetah html+django html+evoque html+genshi html+mako html+myghty html+php \
html+smarty ini io irc java javac-messages js js+cheetah js+django js+genshitext js+mako js+myghty \
js+php js+erb js+smarty jsp lighty lhs llvm logtalk lua make mako matlab matlabsession minid \
modelica modula2 trac-wiki moocode multi mupad mxml myghty mysql nasm newspeak nginx numpy objdump \
objective-c objective-j ocaml ooc perl php text pov prolog python python3 py3tb pycon pytb ragel \
ragel-c ragel-cpp ragel-d ragel-java ragel-objc ragel-ruby raw rconsole rebol redcode rst rhtml rb \
rbcon splus sass scala scheme smalltalk smarty sql sqlite3 squidconf tcl tcsh tex diff vala vb.net \
vim xml xml+cheetah xml+django xml+evoque xml+mako xml+myghty xml+php xml+erb xml+smarty xslt yaml"
POST_lodgeit="submit=Paste! % % language % % code"
REGEX_RAW_lodgeit='s|^\(https\?://[^/]*/\)show\(/[[:alnum:]]*/\)$|\1raw\2|'
# pinnwand
LANGUAGES_pinnwand="ABAP ActionScript%3 ActionScript Ada ANTLR ANTLR%With%ActionScript%Target \
ANTLR%With%CPP%Target ANTLR%With%C#%Target ANTLR%With%Java%Target ANTLR%With%ObjectiveC%Target \
ANTLR%With%Perl%Target ANTLR%With%Python%Target ANTLR%With%Ruby%Target ApacheConf AppleScript \
AspectJ aspx-cs aspx-vb Asymptote autohotkey AutoIt Awk Base%Makefile Bash Bash%Session Batchfile \
BBCode Befunge BlitzMax Boo Brainfuck Bro BUGS ca65 CBM%BASIC%V2 C C++ C# Ceylon CFEngine3 \
cfstatement Cheetah Clojure CMake c-objdump COBOL COBOLFree CoffeeScript Coldfusion%HTML Common%Lisp \
Coq cpp-objdump Croc CSS CSS+Django/Jinja CSS+Genshi%Text CSS+Lasso CSS+Mako CSS+Myghty CSS+PHP \
CSS+Ruby CSS+Smarty CUDA Cython Darcs%Patch Dart D Debian%Control%file Debian%Sourcelist Delphi dg \
Diff Django/Jinja d-objdump DTD Duel Dylan DylanLID Dylan%session eC ECL Elixir Elixir%iex%session \
Embedded%Ragel ERB Erlang Erlang%erl%session Evoque Factor Fancy Fantom Felix Fortran FoxPro FSharp \
GAS Genshi Genshi%Text Gettext%Catalog Gherkin GLSL Gnuplot Go GoodData-CL Gosu Gosu%Template Groff \
Groovy Haml Haskell haXe HTML+Cheetah HTML+Django/Jinja HTML+Evoque HTML+Genshi HTML HTML+Lasso \
HTML+Mako HTML+Myghty HTML+PHP HTML+Smarty HTML+Velocity HTTP Hxml Hybris IDL INI Io Ioke IRC%logs \
Jade JAGS Java JavaScript+Cheetah JavaScript+Django/Jinja JavaScript+Genshi%Text JavaScript \
JavaScript+Lasso JavaScript+Mako JavaScript+Myghty JavaScript+PHP JavaScript+Ruby JavaScript+Smarty \
Java%Server%Page JSON Julia%console Julia Kconfig Koka Kotlin Lasso Lighttpd%configuration%file \
Literate%Haskell LiveScript LLVM Logos Logtalk Lua Makefile Mako MAQL Mason Matlab Matlab%session \
MiniD Modelica Modula-2 MoinMoin/Trac%Wiki%markup Monkey MOOCode MoonScript Mscgen MuPAD MXML Myghty \
MySQL NASM Nemerle NewLisp Newspeak Nginx%configuration%file Nimrod NSIS NumPy objdump Objective-C++ \
Objective-C Objective-J OCaml Octave Ooc Opa OpenEdge%ABL Perl PHP PL/pgSQL \
PostgreSQL%console%(psql) PostgreSQL%SQL%dialect PostScript POVRay PowerShell Prolog Properties \
Protocol%Buffer Puppet PyPy%Log Python%3.0%Traceback Python%3 Python%console%session Python \
Python%Traceback QML Racket Ragel%in%C%Host Ragel%in%CPP%Host Ragel%in%D%Host Ragel%in%Java%Host \
Ragel%in%Objective%C%Host Ragel%in%Ruby%Host Ragel Raw%token%data RConsole Rd REBOL Redcode reg \
reStructuredText RHTML RobotFramework RPMSpec Ruby%irb%session Ruby Rust Sass Scala \
Scalate%Server%Page Scaml Scheme Scilab SCSS Shell%Session Smali Smalltalk Smarty Snobol SourcePawn \
sqlite3con SQL SquidConf S Standard%ML Stan systemverilog Tcl Tcsh Tea TeX Text%only Text Treetop \
TypeScript UrbiScript Vala VB.net Velocity verilog VGL vhdl VimL XML+Cheetah XML+Django/Jinja \
XML+Evoque XML+Lasso XML+Mako XML+Myghty XML+PHP XML+Ruby XML+Smarty XML+Velocity XML XQuery XSLT \
Xtend YAML"
LANGUAGE_VALUES_pinnwand="abap as3 as ada antlr antlr-as antlr-cpp antlr-csharp antlr-java \
antlr-objc antlr-perl antlr-python antlr-ruby apacheconf applescript aspectj aspx-cs aspx-vb asy ahk \
autoit awk basemake bash console bat bbcode befunge blitzmax boo brainfuck bro bugs ca65 cbmbas c \
cpp csharp ceylon cfengine3 cfs cheetah clojure cmake c-objdump cobol cobolfree coffee-script cfm \
common-lisp coq cpp-objdump croc css css+django css+genshitext css+lasso css+mako css+myghty css+php \
css+erb css+smarty cuda cython dpatch dart d control sourceslist delphi dg diff django d-objdump dtd \
duel dylan dylan-lid dylan-console ec ecl elixir iex ragel-em erb erlang erl evoque factor fancy fan \
felix fortran Clipper fsharp gas genshi genshitext pot Cucumber glsl gnuplot go gooddata-cl gosu gst \
groff groovy haml haskell hx html+cheetah html+django html+evoque html+genshi html html+lasso \
html+mako html+myghty html+php html+smarty html+velocity http haxeml hybris idl ini io ioke irc jade \
jags java js+cheetah js+django js+genshitext js js+lasso js+mako js+myghty js+php js+erb js+smarty \
jsp json jlcon julia kconfig koka kotlin lasso lighty lhs live-script llvm logos logtalk lua make \
mako maql mason matlab matlabsession minid modelica modula2 trac-wiki monkey moocode moon mscgen \
mupad mxml myghty mysql nasm nemerle newlisp newspeak nginx nimrod nsis numpy objdump objective-c++ \
objective-c objective-j ocaml octave ooc opa openedge perl php plpgsql psql postgresql postscript \
pov powershell prolog properties protobuf puppet pypylog py3tb python3 pycon python pytb qml racket \
ragel-c ragel-cpp ragel-d ragel-java ragel-objc ragel-ruby ragel raw rconsole rd rebol redcode \
registry rst rhtml RobotFramework spec rbcon rb rust sass scala ssp scaml scheme scilab scss \
shell-session smali smalltalk smarty snobol sp sqlite3 sql squidconf splus sml stan systemverilog \
tcl tcsh tea tex text text treetop ts urbiscript vala vb.net velocity verilog vgl vhdl vim \
xml+cheetah xml+django xml+evoque xml+lasso xml+mako xml+myghty xml+php xml+erb xml+smarty \
xml+velocity xml xquery xslt xtend yaml"
EXPIRATIONS_pinnwand="1day 1week 1month never"
POST_pinnwand="submit=Paste! % % lexer expiry % code"
REGEX_RAW_pinnwand='s|^\(https\?://[^/]*/\)show\(/[[:alnum:]]*/\?\)$|\1raw\2|'

### errors
die() {
	echo "$@" >&2
	exit 1
}

requiredarg() {
	[[ -z $2 ]] && die "$0: option $1 requires an argument"
	((args++))
}

notreadable() {
	die "The input source: \"$1\" is not readable. Please specify a readable input source."
}

noxclip() {
	cat <<EOF >&2
Could not find xclip on your system. In order to use --x$1 you must either
emerge x11-misc/xclip or define x_$1() globally in /etc/wgetpaste.conf or
per user in ~/.wgetpaste.conf to use another program (such as e.g. xcut or
klipper) to $2 your clipboard.

EOF
	exit 1
}

### conversions

# make comparison of specified languages and expirations case-insensitive
tolower() {
	tr '[:upper:]' '[:lower:]' <<< "$*"
}

compare_tolower() {
	[[ $(tolower "$1") == $(tolower "$2") ]]
}

# escape % (used for escaping), & (used as separator in POST data), + (used as space in POST data), space and ;
escape() {
	sed -e 's|%|%25|g' -e 's|&|%26|g' -e 's|+|%2b|g' -e 's|;|%3b|g' -e 's| |+|g' <<< "$*" || die "sed failed"
}

# if possible convert URL to raw
converttoraw() {
	local regex
	regex=REGEX_RAW_$ENGINE
	if [[ -n ${!regex} ]]; then
		RAWURL=$(sed -e "${!regex}" <<< "$URL")
		[[ -n $RAWURL ]] && return 0
		echo "Convertion to raw url failed." >&2
	else
		echo "Raw download of pastes is not supported by $(getrecipient)." >&2
	fi
	return 1
}

### verification
verifyservice() {
	for s in $SERVICES; do
		compare_tolower "$s" "$*" && return 0
	done
	echo "\"$*\" is not a supported service.$N" >&2
	showservices >&2
	exit 1
}

verifylanguage() {
	local i j l lang count v values
	lang=LANGUAGES_$ENGINE
	count=LANGUAGE_COUNT_$ENGINE
	values=LANGUAGE_VALUES_$ENGINE
	if [[ -n ${!lang} ]]; then
		((i=0))
		for l in ${!lang}; do
			if compare_tolower "$LANGUAGE" "${l//\%/ }"; then
				if [[ -n ${!count} ]]; then
					((LANGUAGE=i+1))
				elif [[ -n ${!values} ]]; then
					((j=0))
					for v in ${!values}; do
						if [[ i -eq j ]]; then
							if [[ ${v} == \% ]]; then
								LANGUAGE=
							else
								LANGUAGE=${v//\%/ }
							fi
							break
						fi
						((j++))
					done
				fi
				return 0
			fi
			((i++))
		done
	else
		[[ $LANGUAGESET = 0 ]] || return 0
	fi
	echo "\"$LANGUAGE\" is not a supported language for $(getrecipient).$N" >&2
	showlanguages >&2
	exit 1
}

verifyexpiration() {
	local i j e expiration count v values
	expiration=EXPIRATIONS_$ENGINE
	count=EXPIRATION_COUNT_$ENGINE
	values=EXPIRATION_VALUES_$ENGINE
	if [[ -n ${!expiration} ]]; then
		((i=0))
		for e in ${!expiration}; do
			if compare_tolower "${EXPIRATION}" "${e//\%/ }"; then
				if [[ -n ${!count} ]]; then
					((EXPIRATION=i+1))
				elif [[ -n {!values} ]]; then
					((j=0))
					for v in ${!values}; do
						if [[ i -eq j ]]; then
							if [[ ${v} == \% ]]; then
								EXPIRATION=
							else
								EXPIRATION=${v//\%/ }
							fi
							break
						fi
						((j++))
					done
				fi
				return 0
			fi
			((i++))
		done
	else
		[[ $EXPIRATIONSET = 0 ]] || return 0
	fi
	echo "\"$EXPIRATION\" is not a supported expiration option for $(getrecipient).$N" >&2
	showexpirations >&2
	exit 1
}

# verify that the pastebin service did not return a known error url. otherwise print a helpful error message
verifyurl() {
	dieifknown() {
		[[ -n ${!1%% *} && ${!1%% *} == $URL ]] && die "${!1#* }"
	}
	local t
	for t in ${!TOO*}; do
		[[ $t == TOO*_$SERVICE ]] && dieifknown "$t"
	done
}

# print a warning if failure is predictable due to the mere size of the paste. note that this is only a warning
# printed. it does not abort.
warnings() {
	warn() {
		if [[ -n $2 && $1 -gt $2 ]]; then
			echo "Pasting > ${3//\%/ } often tend to fail with $SERVICE. Use --verbose or --debug to see the"
			echo "error output from wget if it fails. Alternatively use another pastebin service."
		fi
	}
	local size lines
	size=SIZE_$SERVICE
	warn "$SIZE" "${!size% *}" "${!size#* }"
	lines=LINES_$SERVICE
	warn "$LINES" "${!lines}" "${!lines} lines"
}

### input
getfilenames() {
	for f in "$@"; do
		[[ -f $f ]] || die "$0: $f No such file found."
		SOURCE="files"
		FILES[${#FILES[*]}]="$f"
	done
}

x_cut() {
	if [[ -x $(type -P xclip) ]]; then
		xclip -o || die "xclip failed."
	else
		noxclip cut "read from"
	fi
}

### output
usage() {
	cat <<EOF
Usage: $0 [options] [file[s]]

Options:
    -l, --language LANG           set language (defaults to "$DEFAULT_LANGUAGE")
    -d, --description DESCRIPTION set description (defaults to "stdin" or filename)
    -n, --nick NICK               set nick (defaults to your username)
    -s, --service SERVICE         set service to use (defaults to "$DEFAULT_SERVICE")
    -e, --expiration EXPIRATION   set when it should expire (defaults to "$DEFAULT_EXPIRATION")

    -S, --list-services           list supported pastebin services
    -L, --list-languages          list languages supported by the specified service
    -E, --list-expiration         list expiration setting supported by the specified service

    -u, --tinyurl URL             convert input url to tinyurl

    -c, --command COMMAND         paste COMMAND and the output of COMMAND
    -i, --info                    append the output of \`$INFO_COMMAND\`
    -I, --info-only               paste the output of \`$INFO_COMMAND\` only
    -x, --xcut                    read input from clipboard (requires x11-misc/xclip)
    -X, --xpaste                  write resulting url to the X primary selection buffer (requires x11-misc/xclip)
    -C, --xclippaste              write resulting url to the X clipboard selection buffer (requires x11-misc/xclip)

    -r, --raw                     show url for the raw paste (no syntax highlighting or html)
    -t, --tee                     use tee to show what is being pasted
    -v, --verbose                 show wget stderr output if no url is received
        --completions             emit output suitable for shell completions (only affects --list-*)
        --debug                   be *very* verbose (implies -v)

    -h, --help                    show this help
    -g, --ignore-configs          ignore /etc/wgetpaste.conf, ~/.wgetpaste.conf etc.
        --version                 show version information

Defaults (DEFAULT_{NICK,LANGUAGE,EXPIRATION}[_\${SERVICE}] and DEFAULT_SERVICE)
can be overridden globally in /etc/wgetpaste.conf or /etc/wgetpaste.d/*.conf or
per user in any of ~/.wgetpaste.conf or ~/.wgetpaste.d/*.conf.

An additional http header can be passed by setting HEADER_\${SERVICE} in any of the
configuration files mentioned above. For example, authenticating with github gist:
HEADER_gists="Authorization: token 1234abc56789..."

In the case of github gist you can also set PUBLIC_gists='false' if you want to
default to secret instead of public gists.
EOF
}

showservices() {
	local max s IND INDV engine url d
	if [[ -n $COMPLETIONS ]]; then
		for s in $SERVICES; do
			if [[ -n $VERBOSE ]]; then
				d=URL_$s && echo "$s:${!d% *}"
			else
				echo "$s"
			fi
		done
		exit 0
	fi
	echo "Services supported: (case sensitive):"
	max=4
	for s in $SERVICES; do
		[[ ${#s} -gt $max ]] && max=${#s}
	done
	((IND=6+max))
	if [[ $VERBOSE ]]; then
		max=0
		for s in $SERVICES; do
			s=URL_$s
			s=${!s% *}
			[[ ${#s} -gt $max ]] && max=${#s}
		done
		((INDV=3+max+IND))
		engine=" $E[${INDV}G| Pastebin engine:"
	fi
	echo "   Name: $E[${IND}G| Url:$engine"
	echo -ne "   "; for((s=3;s<${INDV:-${IND}}+17;s++)); do (( $s == IND-1 || $s == INDV-1 )) && echo -ne "|" || echo -ne "="; done; echo
	for s in $SERVICES; do
		[[ $s = $DEFAULT_SERVICE ]] && d="*" || d=" "
		[[ $VERBOSE ]] && engine=ENGINE_$s && engine="$E[${INDV}G| ${!engine}"
		url=URL_$s
		url=${!url% *}
		echo "   $d$s $E[${IND}G| $url$engine"
	done | sort
}

printlist() {
	while [[ -n $1 ]]; do
		echo "${1//\%/ }"
		shift
	done
}

showlanguages() {
	local l lang d
	lang=LANGUAGES_$ENGINE
	[[ -n $COMPLETIONS ]] && printlist ${!lang} | sort && exit 0
	echo "Languages supported by $(getrecipient) (case sensitive):"
	[[ -z ${!lang} ]] && echo "$N\"$ENGINE\" has no support for setting language." >&2 && exit 1
	for l in ${!lang}; do
		[[ ${l//\%/ } = $DEFAULT_LANGUAGE ]] && d="*" || d=" "
		echo "   $d${l//\%/ }"
	done | sort
}

showexpirations() {
	local e expiration info d
	expiration=EXPIRATIONS_$ENGINE
	[[ -n $COMPLETIONS ]] && printlist ${!expiration} && exit 0
	echo "Expiration options supported by $(getrecipient) (case sensitive):"
	info=EXPIRATION_INFO_$SERVICE
	[[ -z ${!expiration} ]] && echo "$N${!info}\"$ENGINE\" has no support for setting expiration." >&2 && exit 1
	for e in ${!expiration}; do
		[[ ${e//\%/ } = $DEFAULT_EXPIRATION ]] && d="*" || d=" "
		echo "   $d${e//\%/ }"
	done
}

showurl() {
	echo -n "Your ${2}paste can be seen here: " >&2
	echo "$1"
	[[ $XPASTE ]] && x_paste "$1" primary
	[[ $XCLIPPASTE ]] && x_paste "$1" clipboard
}

x_paste() {
	if [[ -x $(type -P xclip) ]]; then
		echo -n "$1" | xclip -selection $2 -loops 10 &>/dev/null || die "xclip failed."
	else
		noxclip paste "write to"
	fi
}

### Posting helper functions

# get the url to post to
getrecipient() {
	local urls target serv
	for s in $SERVICES tinyurl; do
		if [[ $s == $SERVICE ]]; then
			urls=URL_$SERVICE
			if [[ RAW == $1 ]]; then
				[[ ${!urls} = ${!urls#* } ]] || target=${!urls#* }
			else
				serv="$SERVICE: "
			fi
			echo "${serv}${!urls% *}${target}"
			return 0
		fi
	done
	die "Failed to get url for \"$SERVICE\"."
}

# generate POST data
postdata() {
	local post nr extra f
	post=POST_$ENGINE
	if [[ -n ${!post} ]]; then
		nr=${!post//[^ ]}
		[[ 6 = ${#nr} ]] || die "\"${SERVICE}\" is not supported by ${FUNCNAME}()."
		extra=${!post%% *}
		[[ '%' = $extra ]] || echo -n "$extra&"
		e() {
			post="$1"
			shift
			while [[ -n $1 ]]; do
				f=${post%% *}
				[[ '%' != $f ]] && echo -n "$f=${!1}" && [[ $# -gt 1 ]] && echo -n "&"
				shift
				post=${post#$f }
			done
		}
		e "${!post#$extra }" NICK DESCRIPTION LANGUAGE EXPIRATION CVT_TABS INPUT
	elif [[ function == $(type -t json_$ENGINE) ]]; then
		json_$ENGINE "$DESCRIPTION" "$LANGUAGE" "$INPUT"
	else
		die "\"${SERVICE}\" is not supported by ${FUNCNAME}()."
	fi
}

# get url from response from server
geturl() {
	local regex
	regex=REGEX_URL_$ENGINE
	if [[ -n ${!regex} ]]; then
		[[ needstdout = $1 ]] && return 0
		sed -n -e "${!regex}" <<< "$*"
	else
		[[ needstdout = $1 ]] && return 1
		sed -n -e 's|^.*Location: \(https\{0,1\}://[^ ]*\).*$|\1|p' <<< "$*"
	fi | tail -n1
}

### read cli options

# separate groups of short options. replace --foo=bar with --foo bar
while [[ -n $1 ]]; do
	case "$1" in
		-- )
		for arg in "$@"; do
			ARGS[${#ARGS[*]}]="$arg"
		done
		break
		;;
		--debug )
		set -x
		DEBUG=0
		;;
		--*=* )
		ARGS[${#ARGS[*]}]="${1%%=*}"
		ARGS[${#ARGS[*]}]="${1#*=}"
		;;
		--* )
		ARGS[${#ARGS[*]}]="$1"
		;;
		-* )
		for shortarg in $(sed -e 's|.| -&|g' <<< "${1#-}"); do
			ARGS[${#ARGS[*]}]="$shortarg"
		done
		;;
		* )
		ARGS[${#ARGS[*]}]="$1"
	esac
	shift
done

# set the separated options as input options.
set -- "${ARGS[@]}"

while [[ -n $1 ]]; do
	((args=1))
	case "$1" in
		-- )
		shift && getfilenames "$@" && break
		;;
		-c | --command )
		requiredarg "$@"
		SOURCE="command"
		COMMANDS[${#COMMANDS[*]}]="$2"
		;;
		--completions )
		COMPLETIONS=0
		;;
		-d | --description )
		requiredarg "$@"
		DESCRIPTION="$2"
		;;
		-e | --expiration )
		requiredarg "$@"
		EXPIRATIONSET=0
		EXPIRATION="$2"
		;;
		-E | --list-expiration )
		LISTEXPIRATION=0
		;;
		-h | --help )
		USAGE=0
		;;
		-g | --ignore-configs )
		IGNORECONFIGS=0
		;;
		-i | --info )
		INFO=0
		;;
		-I | --info-only )
		SOURCE=info
		;;
		-l | --language )
		requiredarg "$@"
		LANGUAGESET=0
		LANGUAGE="$2"
		;;
		-L | --list-languages )
		LISTLANGUAGES=0
		;;
		-n | --nick )
		requiredarg "$@"
		NICK=$(escape "$2")
		;;
		-r | --raw )
		RAW=0
		;;
		-s | --service )
		requiredarg "$@"
		SERVICESET="$2"
		;;
		-S | --list-services )
		SHOWSERVICES=0
		;;
		-t | --tee )
		TEE=0
		;;
		-u | --tinyurl )
		requiredarg "$@"
		SERVICE=tinyurl
		SOURCE="url"
		INPUTURL="$2"
		;;
		-v | --verbose )
		VERBOSE=0
		;;
		--version )
		echo "$0, version $VERSION" && exit 0
		;;
		-x | --xcut )
		SOURCE=xcut
		;;
		-X | --xpaste )
		XPASTE=0
		;;
		-C | --xclippaste )
		XCLIPPASTE=0
		;;
		-* )
		die "$0: unrecognized option \`$1'"
		;;
		*)
		getfilenames "$1"
		;;
	esac
	shift $args
done

### defaults
load_configs() {
	if [[ ! $IGNORECONFIGS ]]; then
		# compatibility code
		local f deprecated=
		for f in {/etc/,~/.}wgetpaste{.d/*.bash,}; do
			if [[ -f $f ]]; then
				if [[ -z $deprecated ]]; then
					echo "The config files for wgetpaste have changed to *.conf.$N" >&2
					deprecated=0
				fi
				echo "Please move ${f} to ${f%.bash}.conf" >&2
				source "$f" || die "Failed to source $f"
			fi
		done
		[[ -n $deprecated ]] && echo >&2
		# new locations override old ones in case they collide
		for f in {/etc/,~/.}wgetpaste{.d/*,}.conf; do
			if [[ -f $f ]]; then
				source "$f" || die "Failed to source $f"
			fi
		done
	fi
}
load_configs
[[ $SERVICESET ]] && verifyservice "$SERVICESET" && SERVICE=$(escape "$SERVICESET")
DEFAULT_NICK=${DEFAULT_NICK:-$(whoami)} || die "whoami failed"
DEFAULT_SERVICE=${DEFAULT_SERVICE:-poundpython}
DEFAULT_LANGUAGE=${DEFAULT_LANGUAGE:-Plain Text}
DEFAULT_EXPIRATION=${DEFAULT_EXPIRATION:-1 month}
SERVICE=${SERVICE:-${DEFAULT_SERVICE}}
ENGINE=ENGINE_$SERVICE
ENGINE="${!ENGINE}"
default="DEFAULT_NICK_$SERVICE" && [[ -n ${!default} ]] && DEFAULT_NICK=${!default}
default="DEFAULT_LANGUAGE_$SERVICE" && [[ -n ${!default} ]] && DEFAULT_LANGUAGE=${!default}
default="DEFAULT_EXPIRATION_$SERVICE" && [[ -n ${!default} ]] && DEFAULT_EXPIRATION=${!default}
NICK=${NICK:-$(escape "${DEFAULT_NICK}")}
[[ -z $SOURCE ]] && SOURCE="stdin"
CVT_TABS=No

PUBLIC_gists=${PUBLIC_gists:-true}
[[ "${PUBLIC_gists}" = "true" || "${PUBLIC_gists}" = "false" ]] || die "Invalid setting for PUBLIC_gists. Can either be 'true' or 'false' not '${PUBLIC_gists}'"

INFO_COMMAND=${INFO_COMMAND:-"emerge --info"}
INFO_ARGS=${INFO_ARGS:-"--ignore-default-opts"}

### everything below this should be independent of which service is being used...

# show listings if requested
[[ $USAGE ]] && usage && exit 0
[[ $SHOWSERVICES ]] && showservices && exit 0
[[ $LISTLANGUAGES ]] && showlanguages && exit 0
[[ $LISTEXPIRATION ]] && showexpirations && exit 0

# language and expiration need to be verified before they are escaped but after service and defaults
# have been selected
LANGUAGE=${LANGUAGE:-${DEFAULT_LANGUAGE}}
verifylanguage
LANGUAGE=$(escape "$LANGUAGE")
EXPIRATION=${EXPIRATION:-${DEFAULT_EXPIRATION}}
verifyexpiration
EXPIRATION=$(escape "$EXPIRATION")

# set prompt
if [[ 0 -eq $UID ]]; then
	PS1="#"
else
	PS1=$
fi

# set default description
size=DESCRIPTION_SIZE_$SERVICE
if [[ -z $DESCRIPTION ]]; then
	case "$SOURCE" in
		info )
		DESCRIPTION="$PS1 $INFO_COMMAND;"
		;;
		command )
		DESCRIPTION="$PS1"
		for c in "${COMMANDS[@]}"; do
			DESCRIPTION="$DESCRIPTION $c;"
		done
		;;
		files )
		DESCRIPTION="${FILES[@]}"
		;;
		* )
		DESCRIPTION="$SOURCE"
		;;
	esac
	if [[ -n ${!size} && ${#DESCRIPTION} -gt ${!size} ]]; then
		DESCRIPTION="${DESCRIPTION: -${!size}}"
	fi
else
	if [[ -n ${!size} && ${#DESCRIPTION} -gt ${!size} ]]; then
		die "Your description (${#DESCRIPTION} bytes) is too long. Shorten it to fit within ${!size} bytes."
	fi
fi

# create tmpfile for use with tee
if [[ $TEE ]]; then
	TMPF=$(mktemp /tmp/wgetpaste.XXXXXX)
	[[ -f $TMPF ]] || die "Could not create a temporary file for use with tee."
fi

# read input
case "$SOURCE" in
	url )
	INPUT="${INPUTURL}"
	;;
	command )
	for c in "${COMMANDS[@]}"; do
		if [[ $TEE ]]; then
			echo "$PS1 $c$N$(bash -c "$c" 2>&1)$N" | tee -a "$TMPF"
		else
			INPUT="$INPUT$PS1 $c$N$(bash -c "$c" 2>&1)$N$N"
		fi
	done
	;;
	info )
	if [[ $TEE ]]; then
		echo "$PS1 $INFO_COMMAND$N$($INFO_COMMAND $INFO_ARGS 2>&1)" | tee "$TMPF"
	else
		INPUT="$PS1 $INFO_COMMAND$N$($INFO_COMMAND $INFO_ARGS 2>&1)"
	fi
	;;
	xcut )
	if [[ $TEE ]]; then
		x_cut | tee "$TMPF"
	else
		INPUT="$(x_cut)"
	fi
	;;
	stdin )
		if [[ $TEE ]]; then
			tee "$TMPF"
		else
			INPUT="$(cat)"
		fi
	;;
	files )
	if [[ ${#FILES[@]} -gt 1 ]]; then
		for f in "${FILES[@]}"; do
			[[ -r $f ]] || notreadable "$f"
			if [[ $TEE ]]; then
				echo "$PS1 cat $f$N$(<"$f")$N" | tee -a "$TMPF"
			else
				INPUT="$INPUT$PS1 cat $f$N$(<"$f")$N$N"
			fi
		done
	else
		[[ -r $FILES ]] || notreadable "$FILES"
		if [[ $TEE ]]; then
			tee "$TMPF" < "$FILES"
		else
			INPUT=$(<"$FILES")
		fi
	fi
	;;
esac
NOINPUT="No input read. Nothing to paste. Aborting."
if [[ $TEE ]]; then
	[[ 0 -eq $(wc -c < "$TMPF") ]] && die "$NOINPUT"
else
	[[ -z $INPUT ]] && die "$NOINPUT"
fi

# append info if needed
if [[ $INFO ]]; then
	DESCRIPTION="$DESCRIPTION $PS1 $INFO_COMMAND;"
	if [[ $TEE ]]; then
		echo "$N$PS1 $INFO_COMMAND$N$($INFO_COMMAND $INFO_ARGS 2>&1)" | tee -a "$TMPF"
	else
		INPUT="$INPUT$N$PS1 $INFO_COMMAND$N$($INFO_COMMAND $INFO_ARGS 2>&1)"
	fi
fi

# now that tee has done its job read data into INPUT
[[ $TEE ]] && INPUT=$(<"$TMPF") && echo

# escape DESCRIPTION and INPUT
if [[ function = $(type -t escape_description_$ENGINE) ]]; then
	DESCRIPTION=$(escape_description_$ENGINE "$DESCRIPTION")
else
	DESCRIPTION=$(escape "$DESCRIPTION")
fi
if [[ function = $(type -t escape_input_$ENGINE) ]]; then
	INPUT=$(escape_input_$ENGINE "$INPUT")
else
	INPUT=$(escape "$INPUT")
fi

# print friendly warnings if max sizes have been specified for the pastebin service and the size exceeds that
SIZE=$(wc -c <<< "$INPUT")
LINES=$(wc -l <<< "$INPUT")
warnings >&2

# set recipient
RECIPIENT=$(getrecipient RAW)

if [[ $SERVICE == tinyurl ]]; then
	URL=$(LC_ALL=C wget -qO - "$RECIPIENT?url=$INPUT")
else
	# create temp file (wget is much more reliable reading
	# large input via --post-file rather than --post-data)
	[[ -f $TMPF ]] || TMPF=$(mktemp /tmp/wgetpaste.XXXXXX)
	if [[ -f $TMPF ]]; then
		postdata > "$TMPF" || die "Failed to write to temporary file: \"$TMPF\"."
		WGETARGS="--post-file=$TMPF"
	else
		# fall back to using --post-data if the temporary file could not be created
		# TABs and new lines need to be escaped for wget to interpret it as one string
		WGETARGS="--post-data=$(postdata | sed -e 's|$|%0a|g' -e 's|\t|%09|g' | tr -d '\n')"
	fi

	header="HEADER_$SERVICE"
	if [[ -n "${!header}" ]]; then
		WGETEXTRAHEADER="--header=${!header}"
	else
		WGETEXTRAHEADER=""
	fi

	# paste it
	WGETARGS="--tries=5 --timeout=60 $WGETARGS"
	if geturl needstdout ; then
		OUTPUT=$(LC_ALL=C wget -O - $WGETARGS ${WGETEXTRAHEADER:+"$WGETEXTRAHEADER"} $RECIPIENT 2>&1)
	else
		OUTPUT=$(LC_ALL=C wget -O /dev/null $WGETARGS ${WGETEXTRAHEADER:+"$WGETEXTRAHEADER"} $RECIPIENT 2>&1)
	fi

	# clean temporary file if it was created
	if [[ -f $TMPF ]]; then
		if [[ $DEBUG ]]; then
			echo "Left temporary file: \"$TMPF\" alone for debugging purposes."
		else
			rm "$TMPF" || echo "Failed to remove temporary file: \"$TMPF\"." >&2
		fi
	fi

	# get the url
	URL=$(geturl "$OUTPUT")
fi

# verify that the pastebin service did not return a known error url such as toofast.html from rafb
verifyurl

# handle the case when there was no location returned
if [[ -z $URL ]]; then
	if [[ $DEBUG || $VERBOSE ]]; then
		die "Apparently nothing was received. Perhaps the connection failed.$N$OUTPUT"
	else
		echo "Apparently nothing was received. Perhaps the connection failed. Enable --verbose or" >&2
		die "--debug to get the output from wget that can help diagnose it correctly."
	fi
fi

# converttoraw() sets RAWURL upon success.
if [[ $RAW ]] && converttoraw; then
	showurl "$RAWURL" "raw "
else
	showurl "$URL"
fi

exit 0
