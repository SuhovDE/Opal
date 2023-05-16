--
-- EXCEL_LOAD  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE OPAL_FRA.Excel_Load AS

FUNCTION check_Code_Length ( p_String IN varchar2, p_Name IN varchar2) return varchar2;

FUNCTION get_ID ( p_Code        IN varchar2,
                  p_Table_Name  IN varchar2) return number;

END Excel_Load;
 
 
/