# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufSetOption mimetype=text/x-makefile %{
    set buffer filetype makefile
}

hook global BufCreate .*/?[mM]akefile %{
    set buffer filetype makefile
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

addhl -group / regions -default content makefile \
   comment '#' '$' '' \
   eval '\$\(' '\)' '\('

addhl -group /makefile/comment fill comment
addhl -group /makefile/eval fill value

addhl -group /makefile/content regex ^[\w.%]+\h*:\s 0:identifier
addhl -group /makefile/content regex \b(ifeq|ifneq|else|endif)\b 0:keyword
addhl -group /makefile/content regex [+?:]= 0:operator

# Commands
# ‾‾‾‾‾‾‾‾

def -hidden _makefile-indent-on-new-line %{
    eval -draft -itersel %{
        # preserve previous line indent
        try %{ exec -draft \;K<a-&> }
        ## If the line above is a target indent with a tab
        try %{ exec -draft Z k<a-x> <a-k>^[^:]+:\s<ret> z i<tab> }
        # cleanup trailing white space son previous line
        try %{ exec -draft k<a-x> s \h+$ <ret>d }
        # indent after ifeq, ifneq, else
        try %{ exec -draft Z k<a-x> <a-k> ^\h*(ifeq|ifneq|else)\b<ret> z <a-gt> }
    }
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=makefile %{
    addhl ref makefile

    hook window InsertChar \n -group makefile-indent _makefile-indent-on-new-line

    set window comment_selection_chars ""
    set window comment_line_chars "#"
}

hook global WinSetOption filetype=(?!makefile).* %{
    rmhl makefile
    rmhooks window makefile-indent
}
