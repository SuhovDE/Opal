--
-- SAVEINTOBJ  (Procedure) 
--
--  Dependencies: 
--   COND_NODE (Type)
--   COND_NODES (Type)
--   INT_GRP_OBJ (Type)
--   TEST_INT_GRP (Table)
--
CREATE OR REPLACE procedure OPAL_FRA.saveintobj(g int_grp_obj) as
pragma autonomous_transaction;
begin
 insert into test_int_grp values(g);
 commit;
end;
 
 
/