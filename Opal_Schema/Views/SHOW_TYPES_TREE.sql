--
-- SHOW_TYPES_TREE  (View) 
--
--  Dependencies: 
--   ATTR_TYPES (Table)
--   DIMS (Table)
--   DIM_LEVELS (Table)
--   GET_CONST (Function)
--   TYPES_ (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_TYPES_TREE
(ID, DESCR, CD, PARENT_ID, IS_REAL, 
 ORDNO, LVL, TYPE_KIND, UKEY, PARENT_KEY)
BEQUEATH DEFINER
AS 
select ID,DESCR,CD,PARENT_ID,IS_REAL,ORDNO,LVL,type_kind, id ukey, parent_id parent_key
from (
with ftree(ID, DESCR, CD, parent_id, lvl, type_kind/*, hie*/) as(
 select ID, DESCR, CD, parent_id, 1 lvl, type_kind--, to_char(id) hie
  from attr_types t
  where type_kind=get_const('basic_type') and parent_id is null
  union all
 select t.ID, t.DESCR, t.CD, t.parent_id, ft.lvl+1 lvl, t.type_kind--, ft.hie||'/'||t.id hie
  from attr_types t join ftree ft on t.parent_id=ft.id
  where t.type_kind=get_const('basic_type')
)
select ID, DESCR, CD, parent_id, lvl, type_kind, 1 is_real, 0 ordno
 from ftree t
-- order by hie
)
union all
select ID,DESCR,CD,PARENT_ID,IS_REAL,ORDNO,LVL,type_kind, id ukey, parent_id parent_key from (
with ftree_basic as (
select ID, DESCR, CD,
  case when parent_id is not null and get_const('basic_type')=(select type_kind from attr_types where id=ta.parent_id)
       then (select distinct dim_id from dim_levels where dim_id=ta.dim_id and id <> ta.id)
  	   else parent_id end PARENT_ID, 1 is_real,
  ordno, --all attrs of subtype dimension have the same ordno as the correspondent dim level
  type_kind
 from types_ ta
 where type_kind=get_const('dim_type')
union all
select id, d.abbr descr, null cd, null parent_id, 0 is_real, 0 ordno, null type_kind
 from dims d
 where (select count(*) from dim_levels where dim_id=d.id)>1
),
ftree(id, descr, cd, parent_id, is_real, ordno, lvl, type_kind/*, hie*/) as (
select f.id, f.descr, f.cd, f.parent_id, f.is_real, f.ordno, 1 lvl, f.type_kind--, f.type_kind||f.ordno||f.descr hie
 from ftree_basic f where parent_id is null
union all
select f.id, f.descr, f.cd, f.parent_id, f.is_real, f.ordno, ft.lvl+1 lvl, f.type_kind--, ft.hie||'/'||f.type_kind||f.ordno||f.descr
 from ftree_basic f join ftree ft on f.parent_id=ft.id
)
select id, descr, cd, parent_id, is_real, ordno, lvl, type_kind from ftree
--order by hie  --no order currently
);