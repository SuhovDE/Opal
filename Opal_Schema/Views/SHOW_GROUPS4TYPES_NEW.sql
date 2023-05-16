--
-- SHOW_GROUPS4TYPES_NEW  (View) 
--
--  Dependencies: 
--   GET_CONST (Function)
--   SHOW_GROUPS4TYPES_ (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_GROUPS4TYPES_NEW
(OBJ_NAME, CODE, VCODE, DESCR, GRP_ID, 
 TYPE_ID, PARENT_ID, GRP_TYPE, UKEY, PARENT_KEY, 
 IS_LEAF, PREDEFINED, SHOW_IN_FULL, ORDNO_IN_ROOT, DOM_ID, 
 DIM_LEV_ID, FLAGS, IS_REAL_GROUP, LVL, RN, 
 DATE_FROM, DATE_TO, IS_GRP_PRIV, CR_USER)
BEQUEATH DEFINER
AS 
select distinct OBJ_NAME,CODE,VCODE,DESCR||case when date_from is not null then to_char(date_from, 'yyyy.mm.dd')||'-'||to_char(date_to, 'yyyy.mm.dd') end descr,
  GRP_ID,TYPE_ID,PARENT_ID,GRP_TYPE, grp_id UKEY, parent_id PARENT_KEY,IS_LEAF,
  PREDEFINED,SHOW_IN_FULL,ORDNO_IN_ROOT,DOM_ID,DIM_LEV_ID,FLAGS,IS_REAL_GROUP,LVL,RN, DATE_FROM, DATE_TO, IS_GRP_PRIV, CR_USER
 from SHOW_GROUPS4TYPES_ s
 where
  show_in_full=0 or show_in_full=1 and not exists(select 1 from SHOW_GROUPS4TYPES_ where show_in_full=0 and grp_id=s.grp_id and parent_id=s.parent_id) 
   /*OBJ_NAME='DIM_LEV' or
    not exists(select 1 from groups g, groups_gl gl where gl.fid=g.id and gl.gl_id=s.ukey and gl.gl_pid=s.parent_key and predefined='N')*/
;