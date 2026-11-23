%option noyywrap nounput noinput

%{
#include "A1.tab.h"
%}

%%
.      { return DUMMY; }
\n     { return DUMMY; }

%%
