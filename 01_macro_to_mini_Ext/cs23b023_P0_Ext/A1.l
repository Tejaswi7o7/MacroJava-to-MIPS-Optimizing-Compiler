%option noyywrap nounput noinput

%{
#include "A1.tab.h"
%}

%%
"#defineConst"   { return DEFINE_CONST; }
.      { return DUMMY; }
\n     { return DUMMY; }

%%

