--
-- FOR_QRY  (Package Body) 
--
--  Dependencies: 
--   FOR_QRY (Package)
--   CONSTANTS (Package)
--   DIM_LEVELS (Table)
--   ERRORS (Synonym)
--   GROUPS (Table)
--   GRP_D (Table)
--   GRP_TREE (Table)
--   REF_PROCESS (Synonym)
--   RS_CODES4DIMS (Table)
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE BODY OPAL_FRA.for_qry AS
 err_no_lev CONSTANT PLS_INTEGER := 8;

 PROCEDURE Get_Code_Children(dim_lev_id_ dim_levels.id%type, --qry_id qrys.id%type,
  code_ grp_d.dim_lev_code%type, code_children OUT SYS_REFCURSOR) is
 grp_id_ groups.id%type;
BEGIN
 grp_id_ := get_code_id(dim_lev_id_, code_);
 open code_children for
  select D.abbr, d.short
   from grp_tree gt, groups d
   where gt.parent_id=grp_id_ and gt.id=d.ID
   order by 1;
END;
-------------------------------------------------------------------------------------
 function get_code_id(levelid dim_levels.id%type, code_ grp_d.dim_lev_code%type)
   return groups.id%type is
  val grp_d.dim_lev_code%type;
  id_ groups.id%type;
  stt dim_levels.storage_type%type;
 begin
  begin
   select storage_type into stt from dim_levels where id=levelid;
  exception
  when no_data_found then
   errors.raise_err(err_nodim, constants.qry_task, levelid);
  end;
  val := code_;
  if stt=CONSTANTS.DATETYPE then
   begin --standard mask should be added to the DIM_LEVELS table
    select to_char(to_date(code_, r.display_format),
      case r.colname when constants.DAY_DIM then ref_process.day_mask
                     when constants.MONTH_DIM then ref_process.month_mask end
     )
     into val from rs_codes4dims r
     where dim_lev_id=levelid and attr_type_code=constants.code_code;
   exception
   when others then null; --it will return empty id_, and we'll see
   end;
  end if;
  select grp_id into id_ from grp_d
   where dim_lev_id=levelid and dim_lev_code=val;
  return id_;
 exception
 when no_data_found then
  return id_;
 end;
-------------------------------------------------------------------------------------
 procedure get_dates_from_code(dim_lev_code GRP_D.dim_lev_code%TYPE,
    dim_lev DIM_LEVELS.ID%TYPE, dt1 out date, dt2 out date) is
  attr_col VARCHAR2(30);
 begin
  SELECT COL_IN_DIMS INTO attr_col
   FROM DIM_LEVELS WHERE ID=dim_lev;
  IF attr_col=constants.YEAR_DIM THEN
   dt1 := TRUNC(TO_DATE(dim_lev_code, ref_process.year_mask), 'yyyy');
   dt2 := LAST_DAY(ADD_MONTHS(dt1, 11));
  ELSIF attr_col=constants.MONTH_DIM THEN
   dt1 := TO_DATE(dim_lev_code, ref_process.month_mask);
   dt2 := LAST_DAY(dt1);
  ELSIF attr_col=constants.DAY_DIM THEN
   dt1 := TO_DATE(dim_lev_code, ref_process.day_mask);
  ELSE
   errors.raise_err(err_no_lev, Constants.qry_task, attr_col, dim_lev, do_raise=>TRUE);
  END IF;
 end;
-------------------------------------------------------------------------------------
END;
/