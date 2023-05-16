--
-- GET_ATTR_LVL_BASIC  (View) 
--
--  Dependencies: 
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   ATTRS2RECS (Table)
--   RECS_TREE (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.GET_ATTR_LVL_BASIC
(RNG, CUBE_ID, ATTR_ID)
BEQUEATH DEFINER
AS 
select r.rng, ac.CUBE_ID, a.id attr_id
   from recs_tree r, attrs2recs ar, attrs2cubes ac, attrs a
   where r.rec=ar.elem_rec_id and ar.attr_id=coalesce(a.parent_id, a.id)
    and ac.cube_id=r.cube_id and ar.attr_id=ac.attr_id
   	and coalesce(ac.elem_rec_id, ar.elem_rec_id)=ar.elem_rec_id;