--
-- TREE_FNC  (Package) 
--
--  Dependencies: 
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   ATTR_TYPES (Table)
--   CUBES (Table)
--   DIM_LEVELS (Table)
--   GROUPS (Table)
--   GRP_TREE (Table)
--   QRYS_SEL (Table)
--   STANDARD (Package)
--
CREATE OR REPLACE package OPAL_FRA.tree_fnc as
 abbr_len constant pls_integer := 20;
 short_len constant pls_integer := 256;
 full_len constant pls_integer := 4000;
--predefineg groups
 root_not_d constant pls_integer := 0;
--group levels, filled automatically by triggers
 group_level_filled constant pls_integer:=2;
--compatibility of groups
 grp_not_comp constant pls_integer := 0; --not compatible
 grp_full_comp constant pls_integer := 1; --fully compatible
 grp_child_comp constant pls_integer := 2; --compatible for parent attrs/types
 grp_ext_comp constant pls_integer := 3; --compatible, but changes the dimension level
--ATTR_TYPES.CD column values
 cont_type constant attr_types.cd%type := 'C';
 discr_type constant attr_types.cd%type := 'D';
--ATTR_TYPES.TYPE_KIND column values
 basic_type constant attr_types.type_kind%type := 'B';
 dim_type constant attr_types.type_kind%type := 'D';
--GROUPS.PREDEFINED column values
 is_predefined constant groups.predefined%type := 'Y';
 is_temporary constant groups.predefined%type := 'N';
 is_persistant constant groups.predefined%type := 'P';
 is_dimension constant groups.predefined%type := 'D';
--GROUPS.grp_type column values
 attr_group constant groups.grp_type%type := 'A';
 cont_group constant groups.grp_type%type := 'C';
 dim_group constant groups.grp_type%type := 'D';
 ph_group constant groups.grp_type%type := 'P';
--GRP_D.allrest column values
 all_ constant grp_tree.allrest%type := 'A';
 rest constant grp_tree.allrest%type := 'R';
-----------------------------------------------------------------------------------
--type-defined constants
 function get_abbr_len return pls_integer deterministic;
 function get_short_len return pls_integer deterministic;
 function get_full_len return pls_integer deterministic;
-----------------------------------------------------------------------------------
--predefined groups numbers
 function get_root_not_d  return pls_integer deterministic;
-----------------------------------------------------------------------------------
--functions for returning constants for fixed values
 function get_basic_type return attr_types.type_kind%type deterministic;
 pragma restrict_references(get_basic_type, rnds, wnds, wnps);
 function get_dim_type return attr_types.type_kind%type deterministic;
 pragma restrict_references(get_dim_type, rnds, wnds, wnps);
 function get_cont_type return attr_types.cd%type deterministic;
 pragma restrict_references(get_cont_type, rnds, wnds, wnps);
 function get_discr_type return attr_types.cd%type deterministic;
 pragma restrict_references(get_discr_type, rnds, wnds, wnps);
 function get_grp_predefined return groups.predefined%type deterministic;
 pragma restrict_references(get_grp_predefined, rnds, wnds, wnps);
 function get_grp_temporary return groups.predefined%type deterministic;
 pragma restrict_references(get_grp_temporary, rnds, wnds, wnps);
 function get_grp_persistant return groups.predefined%type deterministic;
 pragma restrict_references(get_grp_persistant, rnds, wnds, wnps);
 function get_grp_dimension return groups.predefined%type deterministic;
 pragma restrict_references(get_grp_dimension, rnds, wnds, wnps);
 function get_attr_group return groups.grp_type%type deterministic;
 pragma restrict_references(get_attr_group, rnds, wnds, wnps);
 function get_cont_group return groups.grp_type%type deterministic;
 pragma restrict_references(get_cont_group, rnds, wnds, wnps);
 function get_dim_group return groups.grp_type%type deterministic;
 pragma restrict_references(get_dim_group, rnds, wnds, wnps);
 function get_ph_group return groups.grp_type%type deterministic;
 pragma restrict_references(get_ph_group, rnds, wnds, wnps);
 function get_all_ return grp_tree.allrest%type deterministic;
 pragma restrict_references(get_all_, rnds, wnds, wnps);
 function get_rest return grp_tree.allrest%type deterministic;
 pragma restrict_references(get_rest, rnds, wnds, wnps);
-----------------------------------------------------------------------------------
 function nearest_dim( --Nearest (in types tree up) dimension level for a type
   type_id attrs.attr_type%type)
  return dim_levels.id%type deterministic;
 pragma restrict_references(nearest_dim, wnds, wnps);
-----------------------------------------------------------------------------------
 function grp_dim_level( --lowest level of dimensional group
   grp_id_ groups.id%type)
  return dim_levels.id%type;
 pragma restrict_references(grp_dim_level, wnds, rnps, wnps);
-----------------------------------------------------------------------------------
 function get_grp_key( --Global group key in SHOW_GROUPS4ATTRS
   keystr varchar2) return pls_integer;
 pragma restrict_references(grp_dim_level, wnds, rnps, wnps);
-----------------------------------------------------------------------------------
 function get_storage_type( --Storage type of a type
   id_ attr_types.id%type) return attr_types.id%type;
 pragma restrict_references(get_storage_type, wnds, rnps, wnps);
-----------------------------------------------------------------------------------
function get_show(grp_id groups.id%type, dim_lev_id dim_levels.id%type,
  basic_attr_id attrs.id%type, cube_id cubes.id%type, noshow qrys_sel.noshow%type := null)
 return attrs2cubes.show%type;
 pragma restrict_references(get_show, wnds);
 pragma restrict_references(tree_fnc, rnds, wnds, rnps, wnps);
end;
 
 
/