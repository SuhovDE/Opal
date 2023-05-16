--
-- SAVEGRPOBJ  (Procedure) 
--
--  Dependencies: 
--   DIM_GRP_OBJ (Type)
--   TEST_DIM_GRP (Table)
--   TREE_NODE (Type)
--   TREE_NODES (Type)
--
CREATE OR REPLACE procedure OPAL_FRA.savegrpobj(g dim_grp_obj) as
pragma autonomous_transaction;
begin
 insert into test_dim_grp values(g);
 commit;
end;
 
 
/