DEFINE L_BUF_GET=10000
DEFINE L_BUF_GET_BY_EXEC=1000
DEFINE ARG=&&1.
DEFINE MSG='Listando cursores com BUFFER_GETS > &L_BUF_GET. OR BUFFER_GETS/EXECUTION > &L_BUF_GET_BY_EXEC..'

@do.getcursor.s@ql &arg.

PROMPT Para obter a listagem completa de cursores use @GetCursorD &arg.
PROMPT
UNDEFINE L_BUF_GET L_BUF_GET_BY_EXEC V_SID V_INST