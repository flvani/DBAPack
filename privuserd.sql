DEFINE OBJGRANT=SIM
DEFINE SINONIMOS=SIM

@@ do.privuser.sql &1.

PROMPT Para obter o resumo de privil�gios use @privuser "&1."
PROMPT

UNDEFINE 1 OBJGRANT SINONIMOS

