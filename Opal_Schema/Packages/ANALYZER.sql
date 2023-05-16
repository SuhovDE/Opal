--
-- ANALYZER  (Package) 
--
--  Dependencies: 
--   CONDELEMLIST (Type)
--   CONDELEMOBJ (Type)
--   CONDEXPRLIST (Type)
--   CONDEXPROBJ (Type)
--   CUBES (Table)
--   DIMFILTERLIST (Type)
--   DIMFILTEROBJ (Type)
--   DIMLEVELLIST (Type)
--   DIMLEVELOBJ (Type)
--   FOLDERS (Table)
--   LANGUAGES (Table)
--   QRYS (Table)
--   QRYSELLIST (Type)
--   QRYSELOBJ (Type)
--   QUERYOBJ (Type)
--   RECS2CUBES (Table)
--   RECS_TREE (View)
--   RS4DIM_OBJ (Type)
--   RS4DIM_OBJLIST (Type)
--   TSTRINGS250 (Synonym)
--   VALFUNCTIONLIST (Type)
--   VALFUNCTIONOBJ (Type)
--   XMLTYPE (Synonym)
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE OPAL_FRA.Analyzer
AS
  -- 1.0 Marian 06.05.2004: Created this package.
  --            Please each time when version number change make the
  --            change in package body as well.
  PKG_VERSION CONSTANT NUMBER := 2.4;
  version_id pls_integer;
  FUNCTION RtmCheck RETURN NUMBER;

  TYPE RecLevelInfo IS RECORD
  (
      ATTR_ID INTEGER,
      NAME    VARCHAR2(50)
  );
  TYPE TblLevelInfos IS TABLE OF RecLevelInfo;
  TYPE RecLevelType IS RECORD
  (
      CODE VARCHAR2(20),
      NAME VARCHAR2(255)
  );
  TYPE TblLevelTypes IS TABLE OF RecLevelType;
  TYPE RecFncInfo IS RECORD
  (
      FNC_ID   VARCHAR2(20),
      FNC_NAME VARCHAR2(255),
	  is_default INTEGER
  );
  TYPE TblFncInfos   IS TABLE OF RecFncInfo;

  ROOT_FOLDER constant folders.scode%type := 'ROOT';
  is_private_no constant qrys.is_private%type := 'N'; --no grants for no creator
  is_private_ro constant qrys.is_private%type := 'R'; --read_only grants for no creator
  is_private_pu constant qrys.is_private%type := 'P'; --public
  cos constant qrys.cr_term%type := sys_context('USERENV','OS_USER');

  PROCEDURE Lang_ListLanguages(Languages OUT SYS_REFCURSOR);
  FUNCTION  Lang_GetCurrent RETURN LANGUAGES.ID%TYPE;
  PROCEDURE Lang_SetCurrent(Language IN LANGUAGES.ID%TYPE);

  --returns root folder name
  function get_root_folder return folders.scode%type;
  --returns root folder ID
  function get_root_folder_id return folders.id%type;

  -- Creates an empty query object.
  FUNCTION  CreateEmptyQuery RETURN QueryOBJ;
  -- Retrive all information about query with query id = "queryid"
  --    If query with queryid is not found then throw "NO_DATA_FOUND" exception.
  FUNCTION  GetQuery(queryid IN INTEGER) RETURN QueryOBJ;
  FUNCTION  GetQueryXml(queryid IN INTEGER) RETURN XMLType;
  -- Set query information for query with id = "queryid"
  --    If query with queryid is not found then throw "NO_DATA_FOUND" exception.
  --    If querydata is null or invalid then throw RAISE_APPLICATION_ERROR(-20000, '...');
  PROCEDURE SetQuery(queryid IN INTEGER, querydata IN QueryOBJ, tmp qrys.tmp%type := null);
  -- Create new query and return the new query id
  --    If querydata is null or invalid then throw RAISE_APPLICATION_ERROR(-20000, '...');
  PROCEDURE SetQueryXml(queryid IN INTEGER, querydata IN XMLType, tmp qrys.tmp%type := null);
  FUNCTION  AddQuery(querydata IN QueryOBJ, tmp qrys.tmp%type := null, queryid IN INTEGER := null) RETURN INTEGER;
  -- Delete query with id = "queryid"
  --    If query with queryid is not found then throw "NO_DATA_FOUND" exception.
  FUNCTION  AddQueryXml(querydata IN XMLType, tmp QRYS.tmp%TYPE := NULL, queryid IN INTEGER := null) RETURN INTEGER;

  PROCEDURE DelQuery(queryid IN INTEGER);



  -- Return the list of all levels for top level attribute with ATTR_ID = "b_attr_id"
  -- Return value Sample: [(100, 'Regions'), (101, 'Countries'), (102, 'Cities'), (103, 'Airports')]
  --     If b_attr_id was not found then function should throw exception "NO_DATA_FOUND"
  PROCEDURE ListDimLevels (b_attr_id IN INTEGER, levelsinfo OUT TblLevelInfos);
  PROCEDURE ListDimLevels (b_attr_id IN INTEGER, levelsinfo OUT SYS_REFCURSOR);
  PROCEDURE ListGrpLevels (b_attr_id IN INTEGER, show_all IN INTEGER, levelsinfo OUT SYS_REFCURSOR);
  PROCEDURE ListGrpLevels (b_attr_id IN INTEGER, levelsinfo OUT TblLevelInfos, show_all boolean := true);
  PROCEDURE ListGrpLevels (b_attr_id IN INTEGER, levelsinfo OUT SYS_REFCURSOR, show_all boolean := true);

  -- Return the list with levels types for attribute with ATTR_ID = "attr_id"
  -- Return value sample: [('IATA', 'IATA Codes'), ('ICAO', 'ICAO Codes'), ('NAME', 'Names'), ('STBUA', 'Stabua Codes')]
  --     If b_attr_id was not found then function should throw exception "NO_DATA_FOUND"
  PROCEDURE ListLevelTypes(  attr_id IN INTEGER, levelsinfo OUT TblLevelTypes);
  PROCEDURE ListLevelTypes(  attr_id IN INTEGER, levelsinfo OUT SYS_REFCURSOR);

  -- Return the list withh all functions available for top level attribute with ATTR_ID = "b_attr_id"
  -- Return value Sample: [('SUM', 'Sum'), ('MIN', 'Minimum'), ('MAX', 'Maximum')]
  --     If b_attr_id was not found then function should throw exception "NO_DATA_FOUND"
  PROCEDURE ListFunctions (b_attr_id IN INTEGER, levelsinfo OUT TblFncInfos);
  PROCEDURE ListFunctions (b_attr_id IN INTEGER, levelsinfo OUT SYS_REFCURSOR);

--Returns levels of recordset
  PROCEDURE ListRsLevels (dim_lev_id_ IN INTEGER, levelsinfo OUT SYS_REFCURSOR);

  PROCEDURE testqry;
  PROCEDURE rename_qry(qry_id_ QRYS.ID%TYPE, new_abbr qrys.abbr%TYPE,
    new_short qrys.short%TYPE := null);
  PROCEDURE add_qry2folder(qry_id_ QRYS.ID%TYPE, folder_id_ FOLDERS.ID%TYPE := null);
  PROCEDURE del_qry_from_folder(qry_id_ QRYS.ID%TYPE, folder_id_ FOLDERS.ID%TYPE);
  -- Marian (bgn): added extra methods for folder management
  FUNCTION  addFolder   (FolderName   IN VARCHAR2,
                         FolderDesc   IN VARCHAR2        := '',
                         ParentFolder IN FOLDERS.ID%TYPE := NULL) RETURN FOLDERS.ID%TYPE;
  PROCEDURE deleteFolder(Folder       IN FOLDERS.ID%TYPE, force pls_integer := 0);
  PROCEDURE moveFolder  (Folder       IN FOLDERS.ID%TYPE,
                         NewParent    IN FOLDERS.ID%TYPE);
  PROCEDURE setupFolder (Folder       IN FOLDERS.ID%TYPE,
                         FolderName   IN VARCHAR2,
                         FolderDesc   IN VARCHAR2);
  -- Marian (end)
--deletes all the temporary queries
  procedure delquery_tmp(qry_id_ qrys.id%type := null);
--inserts status='A', if status is used
  procedure add_fr_status(id_ qrys.id%type);
  function get_qry_folders(id_ qrys.id%type) return tstrings250;
  function get_qry_folders_xml(id_ qrys.id%type) return xmltype;
  function put_qry_folders(folders_list tstrings250) return qrys.id%type;
  function put_qry_folders(folders_list xmltype) return qrys.id%type;
  procedure set_version(version_id_ pls_integer);
  function get_version return pls_integer deterministic;
  function get_level_name(cube_id_ cubes.id%type, rng_ recs_tree.rng%type) return recs2cubes.lvl_name%type;
END;
/