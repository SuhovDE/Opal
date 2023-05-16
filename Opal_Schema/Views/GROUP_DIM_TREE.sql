--
-- GROUP_DIM_TREE  (View) 
--
--  Dependencies: 
--   GROUPS (Table)
--   GRP_D_ (View)
--   GRP_TREE (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.GROUP_DIM_TREE
(ID, PREDEFINED, GRP_TYPE, IS_LEAF, TYPE_ID, 
 DIM_ID, GRP_SUBTYPE, DOM_ID, IS_GRP_PRIV, CR_USER, 
 SUF, ABBR, SHORT, FULL, LEV, 
 ORDNO, PARENT_ID, DIM_LEV_ID, DIM_LEV_CODE, DATE_FROM, 
 DATE_TO)
BEQUEATH DEFINER
AS 
with ftree_basic as (
select
  g1.*, coalesce(d.ordno, 0) ordno, parent_id, d.dim_lev_id, d.dim_lev_code, t.date_from, t.date_to
  from grp_tree t join groups g1 on t.id=g1.id left outer join grp_d_ d on g1.id=d.grp_id
),
/*recursive*/ ftree(ID, PREDEFINED, GRP_TYPE, IS_LEAF, TYPE_ID, DIM_ID, GRP_SUBTYPE, DOM_ID, IS_GRP_PRIV, CR_USER, SUF, ABBR, SHORT, FULL, lvl,
   ordno, parent_id, dim_lev_id, dim_lev_code, date_from, date_to, hie) as (
 select f.ID, f.PREDEFINED, f.GRP_TYPE, f.IS_LEAF, f.TYPE_ID, f.DIM_ID, f.GRP_SUBTYPE, f.DOM_ID, f.IS_GRP_PRIV, f.CR_USER, f.SUF, f.ABBR, f.SHORT, f.FULL,
   1 lvl, f.ordno, f.parent_id, f.dim_lev_id, f.dim_lev_code, f.date_from, f.date_to, f.dim_lev_code hie
  from ftree_basic f where f.id=-f.dim_id and f.parent_id is null
 union all
 select f.ID, f.PREDEFINED, f.GRP_TYPE, f.IS_LEAF, f.TYPE_ID, f.DIM_ID, f.GRP_SUBTYPE, f.DOM_ID, f.IS_GRP_PRIV, f.CR_USER, f.SUF, f.ABBR, f.SHORT, f.FULL,
   ft.lvl+1 lvl, f.ordno, f.parent_id, f.dim_lev_id, f.dim_lev_code, f.date_from, f.date_to, concat(concat(ft.hie, '/'), f.dim_lev_code) hie
  from ftree_basic f join ftree ft on f.parent_id=ft.id
 )
 select ID, PREDEFINED, GRP_TYPE, IS_LEAF, TYPE_ID, DIM_ID, GRP_SUBTYPE, DOM_ID, IS_GRP_PRIV, CR_USER, SUF, ABBR, SHORT, FULL, lvl lev,
   ordno, parent_id, dim_lev_id, dim_lev_code, date_from, date_to from ftree
  order by hie --not clear what is hierarchy in this case, so the present order is wrong
;