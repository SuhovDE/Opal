--
-- DATA_SERVICE  (Package) 
--
--  Dependencies: 
--   CONDELEMLIST (Type)
--   CONDELEMOBJ (Type)
--   CONDEXPRLIST (Type)
--   CONDEXPROBJ (Type)
--   DIMFILTERLIST (Type)
--   DIMFILTEROBJ (Type)
--   DIMLEVELLIST (Type)
--   DIMLEVELOBJ (Type)
--   QRYS (Table)
--   QRYSELLIST (Type)
--   QRYSELOBJ (Type)
--   QUERYOBJ (Type)
--   RS4DIM_OBJ (Type)
--   RS4DIM_OBJLIST (Type)
--   VALFUNCTIONLIST (Type)
--   VALFUNCTIONOBJ (Type)
--   XMLTYPE (Synonym)
--
CREATE OR REPLACE package OPAL_FRA.data_service as
 procedure delete_stray_groups;
 procedure after_ref_load;
 procedure ins_dummy_groups;
 procedure dim_tree2tab;
 procedure dim_tree2tab_split;
 procedure ins_dims2groups;
 procedure qry2hist(querydata QUERYOBJ, queryid qrys.id%type);
 procedure qry2hist(querydata XMLType, queryid qrys.id%type);
 procedure mark_qry_imp(queryid qrys.id%type);
 procedure mark_qry_exp(queryid qrys.id%type);
end;
/