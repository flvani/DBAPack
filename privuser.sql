DEFINE OBJGRANT=NAO
DEFINE SINONIMOS=NAO

@@ do.privuser.sql &1.

PROMPT Para obter a lista completa de privil�gios use @privuserd "&1."
PROMPT

UNDEFINE 1 OBJGRANT SINONIMOS

