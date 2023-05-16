--
-- SAVEOBJ  (Procedure) 
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
--   QRYSELLIST (Type)
--   QRYSELOBJ (Type)
--   QUERYOBJ (Type)
--   RS4DIM_OBJ (Type)
--   RS4DIM_OBJLIST (Type)
--   TEST_QUERYOBJ (Table)
--   VALFUNCTIONLIST (Type)
--   VALFUNCTIONOBJ (Type)
--
CREATE OR REPLACE procedure OPAL_FRA.saveobj(qry_obj QueryOBJ) is
 pragma autonomous_transaction;
begin
 delete test_queryobj;
 insert into test_queryobj values(qry_obj);
 commit;
end;
 
 
/