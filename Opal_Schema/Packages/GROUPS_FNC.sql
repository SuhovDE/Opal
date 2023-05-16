--
-- GROUPS_FNC  (Package) 
--
--  Dependencies: 
--   ATTR_TYPES (Table)
--   COND_NODE (Type)
--   DIMS (Table)
--   DIM_GRP_OBJ (Type)
--   GROUPS (Table)
--   GROUPS_GL (Table)
--   GRP_MEMBERS (Type)
--   GRP_TREE (Table)
--   INT_GRP_OBJ (Type)
--   LEAFS4CONDS (Table)
--   QRYS (Table)
--   TN (Type)
--   TREE_NODE (Type)
--   XMLTYPE (Synonym)
--   STANDARD (Package)
--
CREATE OR REPLACE package OPAL_FRA.groups_fnc as
 dummy_grp constant groups.id%type := -1; ---999999999;
 PLACEHOLDER constant pls_integer := -1;
 very_big constant varchar2(30) := '999999999999';
 very_low constant varchar2(30) := '-'||very_big;
 ubcond_lt leafs4conds.op_sign%type := '<';
 ubcond_le leafs4conds.op_sign%type := '<=';
 lbcond_gt leafs4conds.op_sign%type := '>';
 lbcond_ge leafs4conds.op_sign%type := '>=';
 groups_intersect constant pls_integer := -1;
 groups_not_intersect constant pls_integer := 0;
 groups_enclosed_1to2 constant pls_integer := 1;
 groups_enclosed_2to1 constant pls_integer := 2;
 groups_equivalent constant pls_integer := 3;
 type nums is table of pls_integer index by binary_integer;
-- type grp_member is record(id pls_integer, code varchar2(30));
-- type grp_members is table of grp_member;
 type grp_level is record(dim_lev_id pls_integer, dim_id pls_integer, ordno pls_integer, members grp_members);
 type grp_levels is table of grp_level;
 type parsed_group_type is record(grp_id groups.id%type, leafs_only boolean, struct grp_levels,
   all_members tn);
 type parsed_group_types is table of parsed_group_type index by binary_integer;
--return dummy_grp
function get_dummy_grp return groups.id%type deterministic;
--return group's abbr
function get_grp_name(id_ groups.id%type) return varchar2;
--return grp_subtype for interval groups depenting on int_type and ubcond
function get_grp_subtype(int_type pls_integer, ubcond leafs4conds.op_sign%type)
  return groups.grp_subtype%type deterministic;
--return int_type for interval groups depenting on grp_subtype
function get_int_type(grp_subtype groups.grp_subtype%type)
  return pls_integer deterministic;
--deleting a group with ID=grp_id
--del_force=0 - delete, only if the group is not present in queries and other groups
--del_force=1 - delete, only if the group is not present in queries
--del_force=2 - delete in any case, the group is deleted from queries
procedure delete_group(grp_id groups.id%TYPE, del_force pls_integer := 0);
--The following procedures work only for dimensional groups with 1 level:
--inserting a dimensional group, described with dim_grp and returns it's ID
function add_dim_group(dim_grp dim_grp_obj) return groups.id%TYPE;
--inserting a dimensional group, described with dim_grp and returns it's ID
function add_dim_group_xml(dim_grp XMLType) return groups.id%TYPE;
--replaces the interval group with ID=int_grp.grp_id from description int_grp
function add_int_group(int_grp in out nocopy int_grp_obj) return groups.id%TYPE;
--replaces the interval group with ID=int_grp.grp_id from description int_grp
function add_int_group_xml(int_grp in out nocopy XMLType) return groups.id%TYPE;
--replaces the dimensional group with ID=dim_grp.grp_id from description dim_grp
procedure set_dim_group(grp_id groups.id%type, dim_grp dim_grp_obj,
 del_tree boolean := false);
 --replaces the dimensional group with ID=dim_grp.grp_id from description dim_grp
procedure set_dim_group_xml(grp_id groups.id%type, dim_grp XMLType);
--replaces the interval group with ID=int_grp.grp_id from description int_grp
procedure set_int_group(grp_id groups.id%type, int_grp in out nocopy int_grp_obj);
--replaces the interval group with ID=int_grp.grp_id from description int_grp
procedure set_int_group_xml(grp_id groups.id%type, int_grp in out nocopy XMLType);
--reads a dimensional group with ID=grp_id and returns its description
function get_dim_group(grp_id groups.id%TYPE) return dim_grp_obj;
--reads a dimensional group with ID=grp_id and returns its description
function get_dim_group_xml(grp_id groups.id%TYPE) return XMLType;
--reads a dimensional group with ID=grp_id and returns its description
function get_int_group(grp_id_ groups.id%TYPE) return int_grp_obj;
--reads a dimensional group with ID=grp_id and returns its description
function get_int_group_xml(grp_id_ groups.id%TYPE) return XMLType;
--add a node to grp_tree
function add_to_grp_tree(node tree_node, grp_id groups.id%type := null,
  type_id attr_types.id%type := null)
 return pls_integer;
 --add a node to grp_tree
function add_to_grp_tree_xml(node_xml XMLType, grp_id groups.id%type := null,
  type_id attr_types.id%type := null)
 return pls_integer;
--return all qrys, containing a group grp_id_
function get_qrys4grp(grp_id_ groups.id%type) return SYS_REFCURSOR;
--return parents of a group grp_id_
function get_parents4grp(grp_id_ groups.id%type) return  SYS_REFCURSOR;
--add an interval to an interval group
function add_int_to_grp(node in out nocopy cond_node, grp_id_ groups.id%type)
  return pls_integer;
--delete a node from grp_tree
procedure del_from_grp_tree(id_ groups.id%type, grp_id groups.id%type, from_root boolean := false,
  date_from_ grp_tree.date_from%type := null);
--delete a group from a query
procedure del_grp_from_qry(grp_id_ groups.id%type, qry_id_ qrys.id%type);
--delete an interval from an interval group
procedure del_int_from_grp(id_ groups.id%type, grp_id groups.id%type);
--insert a row to group tree
procedure ins_grp_tree(node tree_node,
  grp_id_ groups.id%type, dim_id_ in out dims.id%type, type_id_ in out attr_types.id%type);
--if the group contains any children
procedure check_group(grp_id_ groups.id%type, grp_type groups.grp_type%type := null);
--sets ordno for grp_id_ as a child of parent_id_
procedure set_ordNo(grp_id_ grp_tree.id%type, parent_id_ grp_tree.id%type,
 ordno grp_tree.ordno_in_root%type);
--check, if an interval group pid has duplicate interval names
procedure is_double_int_name(pid grp_tree.parent_id%type);
--exchange ordno between children id1, id2 of the same group parent_id
procedure exchange_ordno(parent_id_ grp_tree.parent_id%type, id1 grp_tree.id%type,
  id2 grp_tree.id%type);
PROCEDURE prefix_group_code(code IN OUT NOCOPY VARCHAR2, ordno PLS_INTEGER);
-- this function return ID of the ROOT of the Groups Tree
function get_Groups_ROOT_ID return GROUPS.ID%type	deterministic;
-- this function return ID of the ROOT of the Nodes Tree
function get_Nodes_ROOT_ID return GROUPS_GL.GL_ID%type		deterministic;
procedure parse_group(grp_id groups.id%type, parsed_group IN OUT NOCOPY parsed_group_type);
procedure get_parse_group_ext(grp_id groups.id%type, parsed_group_ext IN OUT NOCOPY parsed_group_type);
procedure get_parse_group_ext(parsed_group_ parsed_group_type,
  parsed_group_ext IN OUT NOCOPY parsed_group_type);
function print_parsed_group(p parsed_group_type) return varchar2;
function normalize(parsed_group_ parsed_group_type) return parsed_group_type;
--If the group has intersecting elements, 0 - doesn't have, otherwise (crrently -1) - has
function is_group_intersect(id_ groups.id%type) return pls_integer;
--if 2 groups intersect
function are_groups_intersect(grp_id1 groups.id%type, grp_id2 groups.id%type) return pls_integer;
procedure check_grp_priv(id_ groups.id%type); --raises an error, if private group is changed not by the owner
function check_grp_priv_basic(igp groups.is_grp_priv%type) return pls_integer; --fsalse, if private group is changed not by the owner, otherwise trur
procedure check_grp_priv_basic(igp groups.is_grp_priv%type, rc_ pls_integer := null); --raises an error, if private group is changed not by the owner - usage in triggers
function check_grp_priv(id_ groups.id%type) return pls_integer; --fsalse, if private group is changed not by the owner, otherwise trur
function ins2group(predefined_ groups.predefined%type, grp_type_ groups.grp_type%type,
  int_type pls_integer,  name varchar2, description varchar2, type_id_ groups.type_id%type,
  dim_id_ groups.id%type, is_leaf_ groups.dim_id%type, is_grp_priv_ groups.is_grp_priv%type := null,
  cr_user_ groups.cr_user%type := null, full_ groups.full%type := null) return groups.id%type;
end;
/