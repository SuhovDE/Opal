--
-- IS_DIM_GRP  (Function) 
--
--  Dependencies: 
--   ATTR_TYPES (Table)
--   DIM_LEVELS (Table)
--   TYPES_COMP (Table)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE function OPAL_FRA.is_dim_grp(type_ attr_types.id%type, dim_lev_id dim_levels.id%type := null)
  return pls_integer is
  n pls_integer;
 begin
  if dim_lev_id is not null then return 1; end if;
  select 1 into n from types_comp, dim_levels d
    where rownum=1 and type_id=type_ and comp_type_id=d.id;
  return n;
 exception
 when no_data_found then
  return 0;
 end;
 
 
/