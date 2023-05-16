--
-- SHOW_GROUPS4TYPES_OPAL3  (View) 
--
--  Dependencies: 
--   GET_CONST (Function)
--   SHOW_GROUPS4TYPES_BASIC (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_GROUPS4TYPES_OPAL3
(OBJ_NAME, CODE, VCODE, DESCR, GRP_ID, 
 TYPE_ID, PARENT_ID, GRP_TYPE, UKEY, PARENT_KEY, 
 IS_LEAF, PREDEFINED, SHOW_IN_FULL, ORDNO_IN_ROOT, DOM_ID, 
 DIM_LEV_ID, FLAGS, IS_REAL_GROUP, LVL, RN, 
 DATE_FROM, DATE_TO, IS_GRP_PRIV, CR_USER, DIM_LEV_SCODE)
BEQUEATH DEFINER
AS 
select OBJ_NAME,CODE,VCODE,DESCR||case when date_from is not null then to_char(date_from, 'yyyy.mm.dd')||'-'||to_char(date_to, 'yyyy.mm.dd') end descr,
  GRP_ID,TYPE_ID,PARENT_ID,GRP_TYPE, grp_id UKEY, parent_id PARENT_KEY,IS_LEAF,
  PREDEFINED,SHOW_IN_FULL,ORDNO_IN_ROOT,DOM_ID,DIM_LEV_ID,FLAGS,IS_REAL_GROUP,LVL,RN, DATE_FROM, DATE_TO, IS_GRP_PRIV, CR_USER, DIM_LEV_SCODE
 from SHOW_GROUPS4TYPES_basic s
 where
   predefined<>'N';