--
-- DO_GRP_FLAT  (Package) 
--
--  Dependencies: 
--   GRP_TREE (Table)
--
CREATE OR REPLACE PACKAGE OPAL_FRA."DO_GRP_FLAT" as
procedure on_delete(id_ grp_tree.id%type, pid_ grp_tree.parent_id%type);
procedure on_insert(id_ grp_tree.id%type, pid_ grp_tree.parent_id%type,
 ord_ grp_tree.ordno_in_root%type, date_from_ grp_tree.date_from%type, date_to_ grp_tree.date_to%type);
end;
/