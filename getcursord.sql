DEFINE L_BUF_GET=0
DEFINE L_BUF_GET_BY_EXEC=0
DEFINE V_SID=&&1.
DEFINE V_INST=&&2.

PROMPT
PROMPT Todos Cursores Abertos para a sessao: &v_sid.

@do.getcursor.sql &v_sid. &v_inst.

PROMPT Para obter o resumo dos Top Cursores use @GetCursor &v_sid. &v_inst.
PROMPT
UNDEFINE L_BUF_GET L_BUF_GET_BY_EXEC V_SID V_INST