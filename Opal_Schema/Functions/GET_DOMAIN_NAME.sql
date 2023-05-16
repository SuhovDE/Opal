--
-- GET_DOMAIN_NAME  (Function) 
--
--  Dependencies: 
--   ATTR_TYPES (Table)
--   CONSTANTS (Package)
--   DIMS (Table)
--   DOMAINS (Table)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE function OPAL_FRA.get_domain_name(id_ attr_types.id%type) return varchar2 is
 s varchar2(50);
begin
 select d.abbr into s
  from attr_types t, domains d where t.id=id_ and d.id=t.dom_id;
/* select nvl((select d.abbr from dims d, dim_levels dl, types_comp tc
              where rownum=1 and d.parent_id is null and d.id=dl.dim_id
      and dl.id=tc.type_id and tc.comp_type_id=t.dim_lev_id), t.descr)
   into s from attr_types t where id=id_; */
 return s;
exception
when no_data_found then
 select dd.abbr into s from dims dd where scode=constants.dummy_dim;
 return s;
end;
/