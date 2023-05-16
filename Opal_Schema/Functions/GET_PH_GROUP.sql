--
-- GET_PH_GROUP  (Function) 
--
--  Dependencies: 
--   CONSTANTS (Package)
--   DIM_LEVELS (Table)
--   FROM_DB_UTILS (Package)
--   FUNC_ROW (View)
--   GROUPS (Table)
--   GRP_D (Table)
--   GRP_P (Table)
--   REF_PROCESS (Synonym)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE function OPAL_FRA.get_ph_group(id_ groups.id%type) return groups.id%type
 as
 s varchar2(100);
 ss varchar2(100);
 attr_col DIM_LEVELS.COL_IN_DIMS%type;
 msk varchar2(30);
 dd date;
 id_ret groups.id%type;
begin
 for c in (select g.FUNC_ID, g.param, gr.type_id, f.ret_type FROM GRP_P g join groups gr on (gr.id=g.grp_id) join func_row f on (g.func_id=f.id) WHERE g.grp_id=id_) loop
  s := From_Db_Utils.concat_fun(c.param, '', c.func_id);
  s := 'begin :dd:='||s||'; end;';
  if c.ret_type in (CONSTANTS.DATETYPE, CONSTANTS.TIMETYPE) then
   execute immediate s using out dd;
   SELECT COL_IN_DIMS INTO attr_col
    FROM DIM_LEVELS WHERE ID=c.type_id;
   msk := case attr_col when constants.YEAR_DIM THEN ref_process.year_mask
                        when constants.MONTH_DIM THEN ref_process.month_mask
                        when constants.DAY_DIM THEN ref_process.day_mask
          end;
   ss := TO_CHAR(dd, msk);
  else
   execute immediate s using out ss;
  end if;
  select max(grp_id) into id_ret from grp_d where dim_lev_code=ss and dim_lev_id=c.type_id;
  return id_ret;
end loop;
end;
/