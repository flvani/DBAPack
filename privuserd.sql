DEFINE P1=UPPER('&1.')
DEFINE OBJGRANT=SIM
DEFINE SINONIMOS=SIM

@@ do.privuser.sql

PROMPT Para obter o resumo de privilégios use @privuser "&1."
PROMPT

UNDEFINE 1 2 P1 OBJGRANT SINONIMOS

