--
-- FR_STATUS_UTILS  (Package) 
--
--  Dependencies: 
--   ATTRS (Table)
--   CUBES (Table)
--   GROUPS (Table)
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE OPAL_FRA.fr_status_utils AS
 fr_status_code constant attrs.scode%type := 'FR_STATUS';
 fr_status_def_val constant varchar2(1) := 'A';
--return SCODE of FR status attribute
 function get_fr_status_code return attrs.scode%type deterministic result_cache;
--return SCODE of FR status attribute
 function get_fr_status_def_val return varchar2 deterministic result_cache;
--return ID of FR status attribute
 function get_fr_status_id return attrs.id%type deterministic result_cache;
--return TYPE of FR status attribute
 function get_fr_status_type return attrs.attr_type%type deterministic result_cache;
--return group ID of the group with default status value
 function get_fr_status_def_grp return groups.id%type deterministic result_cache;
--return 1 if FR status attribute is active, otherwise 0
 FUNCTION is_fr_status_active RETURN pls_integer deterministic;
 FUNCTION is_fr_status_active(cube_id_ cubes.id%type) RETURN pls_integer deterministic;
END;
/