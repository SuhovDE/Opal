--
-- TREE_FNC  (Package Body) 
--
--  Dependencies: 
--   TREE_FNC (Package)
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   ATTR_TYPES (Table)
--   CONSTANTS (Package)
--   CUBES (Table)
--   DIM_LEVELS (Table)
--   GROUPS (Table)
--   GRP_D (Table)
--   GRP_TREE (Table)
--   QRYS_SEL (Table)
--   STANDARD (Package)
--
CREATE OR REPLACE package body OPAL_FRA.tree_fnc as
 base constant pls_integer := 11;
 maxval constant pls_integer := 2147483647;
----------------------------------------------------------------------------------
 function get_abbr_len return pls_integer is
 begin
  return abbr_len;
 end;
 function get_short_len return pls_integer is
 begin
  return short_len;
 end;
 function get_full_len return pls_integer is
 begin
  return full_len;
 end;
----------------------------------------------------------------------------------
 function get_root_not_d  return pls_integer is
  begin
  return root_not_d;
 end;
-----------------------------------------------------------------------------------
 function get_basic_type return attr_types.type_kind%type  is
 begin
  return basic_type;
 end;
 function get_dim_type return attr_types.type_kind%type  is
 begin
  return dim_type;
 end;
 function get_cont_type return attr_types.cd%type  is
 begin
  return cont_type;
 end;
 function get_discr_type return attr_types.cd%type  is
 begin
  return discr_type;
 end;
 function get_grp_predefined return groups.predefined%type  is
 begin
  return is_predefined;
 end;
 function get_grp_temporary return groups.predefined%type  is
 begin
  return is_temporary;
 end;
 function get_grp_persistant return groups.predefined%type  is
 begin
  return is_persistant;
 end;
 function get_grp_dimension return groups.predefined%type  is
 begin
  return is_dimension;
 end;
 function get_attr_group return groups.grp_type%type  is
 begin
  return attr_group;
 end;
 function get_cont_group return groups.grp_type%type is
 begin
  return cont_group;
 end;
 function get_dim_group return groups.grp_type%type is
 begin
  return dim_group;
 end;
 function get_ph_group return groups.grp_type%type is
 begin
  return ph_group;
 end;
 function get_all_ return grp_tree.allrest%type deterministic is
 begin
  return all_;
 end;
 function get_rest return grp_tree.allrest%type deterministic is
 begin
  return rest;
 end;
----------------------------------------------------------------------------------
 function nearest_dim(type_id attrs.attr_type%type)
  return dim_levels.id%type  is
   id_ attrs.attr_type%type;
   cursor cc is
   select l1.id from (
    select  t.id
     from  attr_types t
     where t.type_kind=dim_type
     start with id=nearest_dim.type_id
 	 connect by t.id=prior t.parent_id
  	 order siblings by t.id
	) a, dim_levels l1--, dim_levels l2
   where a.id=l1.id --and l2.dim_id=l1.dim_id and l1.ordno=l2.ordno+1
   ;
 begin
  open cc; fetch cc into id_; close cc;
  return id_;
 end;
----------------------------------------------------------------------------------
 function grp_dim_level(grp_id_ groups.id%type)
    return dim_levels.id%type is
  dim_lev_id_ dim_levels.id%type;
 begin
  begin
   select distinct last_value(d.id)
     over(order by d.ordno ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
    into dim_lev_id_
    from
      (select id from grp_tree
        start with parent_id=grp_id_
	    connect by prior id=parent_id and parent_id>=0) a,
	   grp_d g, dim_levels d
	 where g.grp_id=a.id and g.dim_lev_id=d.id;
  exception
  when no_data_found then
   null;
  end;
  return dim_lev_id_;
 end;
----------------------------------------------------------------------------------
function get_storage_type(id_ attr_types.id%type) return attr_types.id%type is
  storage_id_ attr_types.id%type;
begin
 select max(storage_type) into storage_id_
  from attr_types a, dim_levels d
  where a.dim_lev_id=d.id and a.id=id_;
 if storage_id_ is null then
  select distinct last_value(a.parent_id)
     over(order by a.lvl ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	into storage_id_
    from
    (
	  select id, parent_id, level lvl from attr_types
        where parent_id is not null
        start with id=id_
	    connect by id=prior parent_id
 	) a;
 end if;
 return storage_id_;
exception
when no_data_found then
 return null;
end;
----------------------------------------------------------------------------------
function get_show(grp_id groups.id%type, dim_lev_id dim_levels.id%type,
  basic_attr_id attrs.id%type, cube_id cubes.id%type, noshow qrys_sel.noshow%type := null)
 return attrs2cubes.show%type is
 show_ attrs2cubes.show%type;
begin
 if grp_id is not null or dim_lev_id is not null or
    noshow is not null then
  return constants.show_key;
 end if;
 select ac.show into show_ from attrs2cubes ac where
	attr_id=basic_attr_id and get_show.cube_id=ac.cube_id;
 return show_;
exception
when no_data_found then
 return constants.show_val;
end;
----------------------------------------------------------------------------------
 function get_grp_key( --Global group key in SHOW_GROUPS4ATTRS
   keystr varchar2)  return pls_integer is
  n integer :=0;
  k pls_integer;
  c char(1);
 begin
  if keystr is not null then
   for i in 1..length(keystr) loop
    c := substr(keystr, i, 1);
    k := case when c between '0' and '9' then to_number(c)
               when i=1 then 0 else base-1 end;
    n := n*base+k;
   end loop;
  end if;
  return mod(n, maxval);
 end;
----------------------------------------------------------------------------------
end;
/