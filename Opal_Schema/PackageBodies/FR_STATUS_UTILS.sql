--
-- FR_STATUS_UTILS  (Package Body) 
--
--  Dependencies: 
--   FR_STATUS_UTILS (Package)
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   CUBES (Table)
--   GROUPS (Table)
--   GRP_D (Table)
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE BODY OPAL_FRA.fr_status_utils AS
 function get_fr_status_code return attrs.scode%type deterministic result_cache is
 begin
  return fr_status_code;
 end;
 function get_fr_status_def_val return varchar2 deterministic result_cache is
 begin
  return fr_status_def_val;
 end;
 function get_fr_status_type return attrs.attr_type%type deterministic result_cache is
  id_ attrs.attr_type%type;
 begin
  select max(attr_type) into id_ from attrs where scode=fr_status_code;
  return id_;
 end;
 function get_fr_status_id return attrs.id%type deterministic result_cache is
  id_ attrs.id%type;
 begin
  select max(id) into id_ from attrs where scode=fr_status_code;
  return id_;
 end;
 function get_fr_status_def_grp return groups.id%type deterministic result_cache is
  id_ groups.id%type;
 begin
  select max(grp_id) into id_ from grp_d where dim_lev_code=fr_status_def_val and dim_lev_id=get_fr_status_type;
  return id_;
 end;
 FUNCTION is_fr_status_active RETURN pls_integer deterministic IS
  tmpVar NUMBER;
 BEGIN
  select count(*) into tmpvar from attrs a, attrs2cubes ac
   where a.scode='FR_STATUS' and a.id=ac.attr_id and ac.excluded is null and rownum<2;
  return tmpvar;
 END;
 FUNCTION is_fr_status_active(cube_id_ cubes.id%type) RETURN pls_integer deterministic IS
  tmpVar NUMBER;
 BEGIN
  select count(*) into tmpvar from attrs2cubes ac
   where ac.attr_id=get_fr_status_id and ac.excluded is null and ac.cube_id=cube_id_;
  return tmpvar;
 END;
END;
/