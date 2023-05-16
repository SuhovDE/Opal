--
-- CONSTANTS  (Package) 
--
--  Dependencies: 
--   ATTRS2CUBES (Table)
--   QRYS_SEL (Table)
--   TASKS (Synonym)
--   STANDARD (Package)
--
CREATE OR REPLACE package OPAL_FRA.constants as
creationsday constant date := date'1980-01-01';
doomsday constant date := date'2100-01-01';
year_mask varchar2(30) := 'YYYY';
month_mask varchar2(30) := 'MM.YYYY';
day_mask varchar2(30) := 'DD.MM.YYYY';
def_start date := to_date('1998', year_mask);
def_end date := to_date('2010', year_mask);
fun_code constant varchar2(10) := 'FUN';
group_code constant varchar2(10) := 'GROUP';
code_code constant varchar2(10) := 'CODE';
show_key constant attrs2cubes.show%type := 'K';
show_val constant attrs2cubes.show%type := 'V';
show_not constant attrs2cubes.show%type := 'N';
inttype constant pls_integer := -1;
numtype constant pls_integer := -3;
chartype constant pls_integer := -4;
datetype constant pls_integer := -5;
timetype constant pls_integer := -6;
qry_task constant tasks.taskid%type := 'QRY';
NOTOP constant varchar2(30) := 'NOT';
LIKEOP constant varchar2(30) := 'LIKE';
INOP constant varchar2(30) := 'IN';
ELSOP constant varchar2(30) := 'ELSE';
ANDOP constant varchar2(30) := 'AND';
OROP constant varchar2(30) := 'OR';
dates_dim constant varchar2(30):= 'DATES';
dummy_dim constant varchar2(30):= 'DUMMY';
DAY_DIM CONSTANT VARCHAR2(30) := 'DAY'; --expand, addind mask to dim_levels???
MONTH_DIM CONSTANT VARCHAR2(30) := 'MONTH';
YEAR_DIM CONSTANT VARCHAR2(30) := 'YEAR';
how_repo_flag constant qrys_sel.how%type := 1;
how_null_flag constant qrys_sel.how%type := 2; --temporary to preserve cmpatibility it was 1
how_rest_flag constant qrys_sel.how%type := 4; --it was 2;
eol constant varchar2(2):= chr(13)||chr(10);
function get_fun_code return varchar2 deterministic;
pragma restrict_references(get_fun_code, WNDS);
function get_group_code return varchar2 deterministic;
pragma restrict_references(get_group_code, WNDS);
function get_code_code return varchar2 deterministic;
pragma restrict_references(get_code_code, WNDS);
function get_year_mask return varchar2 deterministic;
pragma restrict_references(get_year_mask, WNDS);
function get_month_mask return varchar2 deterministic;
pragma restrict_references(get_month_mask, WNDS);
function get_day_mask return varchar2 deterministic;
pragma restrict_references(get_day_mask, WNDS);
function get_show_key return varchar2 deterministic;
pragma restrict_references(get_show_key, WNDS);
function get_show_val return varchar2 deterministic;
pragma restrict_references(get_show_val, WNDS);
function get_show_not return varchar2 deterministic;
pragma restrict_references(get_show_not, WNDS);
function get_inttype return pls_integer deterministic;
pragma restrict_references(get_inttype, WNDS);
function get_numtype return pls_integer deterministic;
pragma restrict_references(get_numtype, WNDS);
function get_chartype return pls_integer deterministic;
pragma restrict_references(get_chartype, WNDS);
function get_datetype return pls_integer deterministic;
pragma restrict_references(get_datetype, WNDS);
function get_timetype return pls_integer deterministic;
pragma restrict_references(get_timetype, WNDS);
function get_how_repo_flag return pls_integer deterministic;
pragma restrict_references(get_how_repo_flag, WNDS);
function get_how_null_flag return pls_integer deterministic;
pragma restrict_references(get_how_null_flag, WNDS);
function get_how_rest_flag return pls_integer deterministic;
function day_of_week(dd date) return pls_integer deterministic;
PRAGMA restrict_references(day_of_week, wnds, rnds, wnps);
pragma restrict_references(get_how_rest_flag, WNDS);
pragma restrict_references(constants, WNDS);
end;
/