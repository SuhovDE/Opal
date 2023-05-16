--
-- FOR_QRY  (Package) 
--
--  Dependencies: 
--   DIM_LEVELS (Table)
--   ERRORS_TXT (Synonym)
--   GROUPS (Table)
--   GRP_D (Table)
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE OPAL_FRA.for_qry AS
 err_nodim ERRORS_TXT.ERRID%type := 15;

 PROCEDURE Get_Code_Children(dim_lev_id_ dim_levels.id%type, --qry_id qrys.id%type,
  code_ grp_d.dim_lev_code%type, code_children OUT SYS_REFCURSOR);

 function get_code_id(levelid dim_levels.id%type, code_ grp_d.dim_lev_code%type)
  return groups.id%type;

 procedure get_dates_from_code(dim_lev_code GRP_D.dim_lev_code%TYPE,
    dim_lev DIM_LEVELS.ID%TYPE, dt1 out date, dt2 out date);
END;
 
/