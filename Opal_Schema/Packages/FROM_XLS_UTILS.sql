--
-- FROM_XLS_UTILS  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE OPAL_FRA.from_xls_utils IS
   FUNCTION get_ID (p_Code            IN varchar2,
                    p_Table_Name      IN varchar2,
					p_col varchar2 default 'c.name.abbr') return binary_integer;

   FUNCTION check_String_Length ( p_String IN varchar2, p_Name IN varchar2,
            p_Length IN Number ) Return varchar2;
   FUNCTION check_Code_Length   ( p_String IN varchar2, p_Name IN varchar2 )
            return varchar2;
   FUNCTION check_Number_Length ( p_Number IN NUMBER, p_Name IN varchar2)
            return number;
   FUNCTION check_Month ( p_Month IN number) return number;
   PROCEDURE delete_Global;
   procedure signal_dupval(msg varchar2);
END from_xls_utils;
 
 
/