--
-- GROUPS_NOT_FROM_D  (View) 
--
--  Dependencies: 
--   GET_CONST (Function)
--   GROUPS (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.GROUPS_NOT_FROM_D
(ID, PREDEFINED, GRP_TYPE, IS_LEAF, TYPE_ID, 
 DIM_ID, GRP_SUBTYPE, DOM_ID, IS_GRP_PRIV, CR_USER, 
 SUF, ABBR, SHORT, FULL)
BEQUEATH DEFINER
AS 
SELECT --+index(g)
 g."ID",g."PREDEFINED",g."GRP_TYPE",g."IS_LEAF",g."TYPE_ID",g."DIM_ID",g."GRP_SUBTYPE",g."DOM_ID",g."IS_GRP_PRIV",g."CR_USER",g."SUF",g."ABBR",g."SHORT",g."FULL"
FROM
  groups g
where predefined in('N', 'P', 'Y') and id<>get_const('root_not_d');