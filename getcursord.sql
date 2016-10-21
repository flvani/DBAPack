DEFINE L_BUF_GET=0
DEFINE L_BUF_GET_BY_EXEC=0
DEFINE ARG=&&1.
DEFINE MSG=''

@do.getcursor.sql &arg.

PROMPT Para obter o resumo dos Top Cursores use @GetCursor &arg.
PROMPT
UNDEFINE L_BUF_GET L_BUF_GET_BY_EXEC ARG