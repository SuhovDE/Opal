--
-- SHOW_FUNC_GRP4ATTRS  (View) 
--
--  Dependencies: 
--   ATTRS (Table)
--   FUNC_GRP (Table)
--   GET_CONST (Function)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_FUNC_GRP4ATTRS
(FUNC_ID, FUNC_NAME, ATTR_ID, IS_DEFAULT)
BEQUEATH DEFINER
AS 
select func_id, func_name, attr_id,
 case when is_def_expr>is_def_non_expr then is_def_expr else is_def_non_expr end is_default
from (
select f.id func_id, f.name func_name, a.id attr_id, f.grp_type, a.storage_type,
  case when (a.expr_id is not null and grp_funs not like '%-AVG%' or grp_funs like '%+AVG%') and f.id='AVG' then 1 else 0 end is_def_expr,
  case when (a.expr_id is null and grp_funs not like '%-SUM%' or grp_funs like '%+SUM%') and f.id='SUM' then 1 else 0 end is_def_non_expr
 from (select * from func_grp where id !='GRP') f, (select id, storage_type, expr_id, nvl(grp_funs, ' ') grp_funs from attrs a ) a
) fa
where (grp_type=get_const('grp_type_nomulti') or
 storage_type in
  (get_const('inttype'), get_const('numtype')) and (is_def_expr=1 or is_def_non_expr=1)) --this condition is to be expanded
;