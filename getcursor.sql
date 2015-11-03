DEFINE L_BUF_GET=10000
DEFINE L_BUF_GET_BY_EXEC=1000
DEFINE V_SID=&&1.
DEFINE V_INST=&&2.

PROMPT
PROMPT Top Cursores Abertos para a sessao: &v_sid.
PROMPT Listando cursores com BUFFER_GETS > &L_BUF_GET. OR BUFFER_GETS/EXECUTION > &L_BUF_GET_BY_EXEC..

@do.getcursor.sql &v_sid. &v_inst.

PROMPT Para obter a listagem completa de cursores use @GetCursorD &v_sid. &v_inst.
PROMPT
UNDEFINE L_BUF_GET L_BUF_GET_BY_EXEC V_SID V_INST