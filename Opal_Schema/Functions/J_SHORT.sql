--
-- J_SHORT  (Function) 
--
--  Dependencies: 
--   QRYS (Table)
--   RECS_TREE (View)
--   DUAL (Synonym)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE function OPAL_FRA.j_short(cube_id_ qrys.cube_id%type, rng_ integer) return varchar2 as
 rc varchar2(4000);
begin
 select json_array(json_object(KEY 'attr_type_code' VALUE 'CODE',
     KEY 'attr_type_name' VALUE '', KEY 'rs_name' VALUE concat('RN', rng_),
     KEY 'rs_display_name' VALUE concat('ID ', (select max(lvl_name) from recs_tree where rng=rng_ and cube_id=cube_id_)),
     KEY 'display_format' VALUE '',
     KEY 'colname' VALUE '',
     KEY 'rs_ftype' VALUE 0,
     KEY 'rs_expr' VALUE '')
    ) into rc from dual;
 return rc;
end;
/