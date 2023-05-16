--
-- SHOW_ATTRS2CUBES  (View) 
--
--  Dependencies: 
--   AREAS (Table)
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   ATTR_TYPES (Table)
--   CUBES (Table)
--   DOMAINS (Table)
--   GET_CONST (Function)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_ATTRS2CUBES
(ATTR_NAME, CUBE_NAME, AREA_NAME, SHOW, DOMAIN_NAME, 
 ID, ATTR_LVL, ORDNO)
BEQUEATH DEFINER
AS 
select
   a.abbr attr_name, c.abbr cube_name, ar.Abbr Area_Name,
	  case when ac.show='V' then 'M' when ac.show='K' then 'D' else ac.show end show,
	  (select coalesce(max(d.abbr), get_const('dummy_dim')) from attr_types t, domains d where t.id=a.attr_type and d.id=t.dom_id) domain_name, a.id,
    ac.rng attr_lvl, ac.ordno
   from
      attrs a join Areas ar on ar.ID = a.Area_ID and ar.id>0
      left outer join attrs2cubes ac on ac.attr_id = a.id
      left outer join cubes c on c.id = ac.cube_id
   where
    a.parent_id is null and ac.excluded is null;