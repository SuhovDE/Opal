--
-- SHOW_GROUPS4TYPES_ORG  (View) 
--
--  Dependencies: 
--   GET_CONST (Function)
--   GROUPS (Table)
--   GROUPS_GL (Table)
--   SHOW_GROUPS4TYPES_ (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_GROUPS4TYPES_ORG
(OBJ_NAME, CODE, VCODE, DESCR, GRP_ID, 
 TYPE_ID, PARENT_ID, GRP_TYPE, UKEY, PARENT_KEY, 
 IS_LEAF, PREDEFINED, SHOW_IN_FULL, ORDNO_IN_ROOT, DOM_ID, 
 DIM_LEV_ID, FLAGS, IS_REAL_GROUP, LVL, RN, 
 DATE_FROM, DATE_TO, IS_GRP_PRIV, CR_USER)
BEQUEATH DEFINER
AS 
select OBJ_NAME,CODE,VCODE,DESCR||case when date_from is not null then to_char(date_from, 'yyyy.mm.dd')||'-'||to_char(date_to, 'yyyy.mm.dd') end descr,
  GRP_ID,TYPE_ID,PARENT_ID,GRP_TYPE,UKEY,PARENT_KEY,IS_LEAF,
  PREDEFINED,SHOW_IN_FULL,ORDNO_IN_ROOT,DOM_ID,DIM_LEV_ID,FLAGS,IS_REAL_GROUP,LVL,RN, DATE_FROM, DATE_TO, IS_GRP_PRIV, CR_USER
 from SHOW_GROUPS4TYPES_ s
 where --predefined<>'N' and
    OBJ_NAME='DIM_LEV' or
    not exists(select 1 from groups g, groups_gl gl where gl.fid=g.id and gl.gl_id=s.ukey and gl.gl_pid=s.parent_key and predefined='N');