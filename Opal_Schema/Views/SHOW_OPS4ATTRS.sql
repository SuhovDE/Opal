--
-- SHOW_OPS4ATTRS  (View) 
--
--  Dependencies: 
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   GET_CONST (Function)
--   OPS4TYPES (Table)
--   SHOW_TYPES (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_OPS4ATTRS
(ATTR_ID, OP_SIGN, SHOW)
BEQUEATH DEFINER
AS 
select a.id attr_id, op_sign, (select max(show) from attrs2cubes where attr_id=a.id) show
 from attrs a, ops4types o, show_types t where
 a.storage_type=o.type_id and
 (a.parent_id is null or a.storage_type not in (get_const('datetype'), get_const('timetype'))) --show nothing for non-basic attrs of date/time type
  and t.id=a.attr_type and (t.type_mask is null or o.op_sign not like '%LIKE%')
 order by 1,2;