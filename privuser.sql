DEFINE P1=UPPER('&1.')
DEFINE OBJGRANT=NAO
DEFINE SINONIMOS=NAO

@@ do.privuser.sql

PROMPT Para obter a lista completa de privilégios use @privuserd "&1."
PROMPT

UNDEFINE 1 2 P1 OBJGRANT SINONIMOS

