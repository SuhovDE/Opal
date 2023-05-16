--
-- ADJUST_META  (Procedure) 
--
--  Dependencies: 
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   ATTR_TYPES (Table)
--   EXPRS (Table)
--   EXPRS_TREE (View)
--   GET_ATTR_LVL_BASIC (View)
--   GET_CONST (Function)
--   RS_CODES4DIMS (Table)
--   SHOW_TYPES (View)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE procedure OPAL_FRA.adjust_meta as
 tmp varchar(100);
 done boolean;
 cursor arc is
  select ac.attr_id, ac.cube_id, a.expr_id, ac.rng
    from attrs2cubes ac join attrs a on ac.attr_id=a.id
    where excluded is null
   order by case when a.expr_id is null then -9999 else a.expr_id end, ac.attr_id;
 cattr_id integer;
 ccube_id integer;
 cexpr_id integer;
 crng integer;
 cursor dfmt is
  select code, concat(
    case when dim_lev_id>0 then (select max(DISPLAY_FORMAT) from RS_CODES4DIMS
     where DIM_LEV_ID=c.DIM_LEV_ID and ATTR_TYPE_CODE=get_const('CODE_CODE'))
    else (select max(concat(type_mask, case when c.storage_type=get_const('NUMTYPE') then substr('0000000000', 1, coalesce(c.attr_precision, type_precision)) end))
     from attr_types where id=c.storage_type and type_mask is not null)
    end, case when c.unit=get_const('UNIT_PRC') then c.unit end) cfmt
   from (
   select id, dim_lev_id, storage_type, attr_precision, unit, 'A' code from attrs
    union all
   select id, dim_lev_id, storage_type, null, null, 'T' from show_types
  ) c;
 ccode varchar(1);
begin
/*goto abeg;*/
/*  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE; */
/* attribute range in cube*/
 done := false;
 open arc;
 while (not done) loop
  fetch arc into cattr_id, ccube_id, cexpr_id, crng;
  done := arc%notfound;
  if not done then
   select min(rng) into crng from get_attr_lvl_basic where attr_id=cattr_id and cube_id=ccube_id;
   if crng is null and cexpr_id is not null then
    select max(a.rng) into crng
     from exprs_tree e join attrs2cubes a on e.attr_id=a.attr_id and a.cube_id=ccube_id
     where e.root_id=cexpr_id;
   end if;
   update attrs2cubes set rng=crng
    where attr_id=cattr_id and cube_id=ccube_id and coalesce(rng, -1)<>coalesce(crng, -1);
  end if;
 end loop;
 close arc;
 commit;
/* display_format*/
 done := false;
 open dfmt;
 while (not done) loop
  fetch dfmt into ccode, tmp;
  done := dfmt%notfound;
  if not done then
   if ccode='A' then
    update attrs set display_format=tmp
     where id=cattr_id and coalesce(display_format, '!')<>coalesce(tmp, '!');
   elsif ccode='T' then
    update attr_types set display_format=tmp
     where id=cattr_id and coalesce(display_format, '!')<>tmp; /*do not overwrite with empty*/
   end if;
  end if;
 end loop;
 close dfmt;
 update RS_CODES4DIMS r set display_format=(select display_format from attr_types where id=r.dim_lev_id)
  where display_format is null  and ATTR_TYPE_CODE=get_const('CODE_CODE')
   and exists(select display_format from attr_types where id=r.dim_lev_id and display_format is not null);
 commit;
/*<<abeg>>*/
/*rs_name in exprs*/
  update exprs e set rs_expr=(select listagg(concat('F:%NO_E', ordno), ';') within group(order by hie, ordno)
   from exprs_tree where root_id=e.id)
   where exists(select 1 from attrs where expr_id=e.id);
 commit;
end;
/