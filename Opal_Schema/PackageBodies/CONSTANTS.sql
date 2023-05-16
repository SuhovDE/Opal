--
-- CONSTANTS  (Package Body) 
--
--  Dependencies: 
--   CONSTANTS (Package)
--   STANDARD (Package)
--
CREATE OR REPLACE package body OPAL_FRA.constants as
 di constant pls_integer := 1-to_char(date'2013-07-29', 'D');

function get_fun_code return varchar2 deterministic is
begin
 return fun_code;
end;
function get_group_code return varchar2 deterministic is
begin
 return group_code;
end;
function get_code_code return varchar2 deterministic is
begin
 return code_code;
end;
function get_year_mask return varchar2 deterministic is
begin
 return year_mask;
end;
function get_month_mask return varchar2 deterministic is
begin
 return month_mask;
end;
function get_day_mask return varchar2 deterministic is
begin
 return day_mask;
end;
function get_show_key return varchar2 deterministic is
begin
 return show_key;
end;
function get_show_val return varchar2 deterministic is
begin
 return show_val;
end;
function get_show_not return varchar2 deterministic is
begin
 return show_not;
end;
function get_inttype return pls_integer deterministic is
begin
 return inttype;
end;
function get_numtype return pls_integer deterministic is
begin
 return numtype;
end;
function get_chartype return pls_integer deterministic is
begin
 return chartype;
end;
function get_datetype return pls_integer deterministic is
begin
 return datetype;
end;
function get_timetype return pls_integer deterministic is
begin
 return timetype;
end;
function get_how_repo_flag return pls_integer deterministic is
begin
 return how_repo_flag;
end;
function get_how_null_flag return pls_integer deterministic is
begin
 return how_null_flag;
end;
function get_how_rest_flag return pls_integer deterministic is
begin
 return how_rest_flag;
end;
function day_of_week(dd date) return pls_integer is
 dr pls_integer := to_char(dd, 'D') +di;
begin
 return case when dr between 1 and 7 then dr when dr<=0 then 7+dr else dr-7 end;
end;
end;
/