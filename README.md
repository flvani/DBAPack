# DBA Pack

This set of scripts was written for Oracle SQL\*Plus command line utility. It uses SQL\*Plus format commands, like PAGESIZE, LINESIZE, FORMAT, PROMPT and so on. Substitution variables are also widely used.

Once you have downloaded the pack, you should extract the files to a folder pointed by SQLPATH environment variable or even place them in the SQL\*Plus starter folder.

The *login.sql* file is reponsible for several environment sets. You should edit it properly.

## Documentation

### This section intends to be a quick reference guide to the scripts:

Enviroment files

* **login.sql** - Use this file to format the SQL*Plus's login preferences
```
    Set the OS variable: 
        DEFINE OS=Linux  
        DEFINE OS=Windows.
```
Sql files

 * **asm[op].sql** - ASM info
 * **awrsql.sql** - Historical information about execution plan for a single SQL, gathered from AWR repo.
```
    @awrsql <sql_id> 
        sql_id - SQL identifier
    e.g.
        @awrsql 9n0dnrf4akbm0
```
 * **circuits.sql** - Shared conection info
 
 * **constraints.sql** - List the constraints associated to a table
```
    @constraints <owner> <table> 
        owner - the name of the schema   
        table - the name of table(s) to be queried - can use wild cards
    e.g.
        @constraints USR_TESTE T%
```
 
 * **dbafreespace[d].sql** - List information about tablespace's free space. For a more detailed report use dbafreespaced.
```
    @dbafreespace <tablespace> 
        tablespace - the name of tablespace(s) to be queried - can use wild cards
    e.g.
        @dbafreespace %
        @dbafreespaced SYSTEM
```
 
 * **detalhesql.sql** - Report source and executions statistics of a statement
```
    @detalhesql <sql_id> 
        sql_id - SQL identifier. See [tops.sql]
    e.g.
        @detalhesql 62jd0x1sdk42m
```
 * **dginst.sql** - Information on running instances and Data Guard status.
 * **dir.sql** - Directory information.
 * **dpmonit.sql** - Datapump monitor - Information on running Data Pump jobs
 * **excludes.sql** - List avaliable sections for use with expdp/impdp.
```
    @excludes <section> 
        section - The name (or part of it) of the section to be listed.
    e.g.
        @excludes %index%
```
 * **expplan.sql** - This script provides a way to get the execution plan info for a statement. The SQL source code should be placed in the *explain.sql* file along with all other relevant sets, like, current_schema, optimizer options and so on. To get the plan info run the expplan script.
```
    @expplan 
        <no-arguments>
    input file:
        explain.sql
    e.g.
        @expplan 
```
 
 * **fknoindex.sql** - Evaluates all reference constraints (FK) of a named schema and indicates the needs for new index creation to avoid high levels of lock. The output of the script will generate a file name *\<schema\>.FkNoIdx.Sql* and it will contains the DDL for the required new indexes
```
    @fknoindex <schema> 
        schema - The name the scheme whose FKs will be checked.
    e.g.
        @fknoindex usr_ecomm
    output file:
        <schema>.FkNoIdx.Sql
```
 * **getDDLTablespaces.sql** - The script generates the DDL to recreate all the tablespaces of a database. It also normalized the size and number of datafiles for each tablespace. The script accepts a pattern to produce the name of the diskgroup where the datafiles will be created. That is such a hardcoded thing and it can be easily modified. The produced DDL will be placed in a file named *c:\cria.tablespaces.\<pattern\>.sql*.
```
    @getDDLTablespaces <pattern>
        pattern - The pattern will compose the name of the diskgroup for the datafiles, this way: +DG_<pattern>_DATA.
    e.g.
        @getDDLTablespaces ecomm
    output file:
        c:\cria.tablespaces.<pattern>.sql
```
  
 * getcursor[d].sql - List, in descending order of Logical IO, of the cached cursors for a session. The script getcursord include even cursores with low number of reads.
```
    @getcursor <sid> <inst>
        sid - session identifier
        inst - instance identifier. For non-RAC systems it is always 1.
    e.g.
        @getcursor 1127 1
```
 * getddl.sql - Invokes dbms_metadata to extract the DDL for an object. For non-schema objects, such as, tablespaces, the last argument should be an asterisk (\*).
```
    @getddl <objtype> <objowner> <objname>
        objtype - type of the object
        objowner - owner of the object
        objname - name of the object
    e.g.
        @getddl view usr_ecomm vw_list_prod
        @getddl materialized_view usr_ecomm mv_list_prod
        @getddl db_link usr_ecomm mylink.domain
        @getddl tablespace system *
```
 * getfontes.sql - Extracts the source for one or more PL/Sql objects of a schema. The script requires a subfolder named *fontes* in which the output files will be placed. Inside it, a folder for each type of object will be created and each object will have its own file.
```
    @getfontes <schema> <objname>
        schema - the owner of the object(s);
        objname - the name of one or more objects using wildcards (%,_).
    e.g.
        @getfontes usr_ecomm pkg_customers
        @getfontes usr_ecomm %
    output file:
       ./fontes/<schema>/<object-type>/<objname>.sql
```
 * getpfile.sql - Produces a list of the non-default parameter set in the database. The output can be used to create a parameter file. Deprecated parameter are marked *(--)*.
 
 * getplan.sql
 * getsql.sql
 * getsqltxt.sql
 * histconn.sql
 * indexes.sql
 * jobs[a].sql
 * limpaobjuser.sql
 * links.sql
 * lockmon.sql
 * login.sql
 * longall.sql
 * longops.sql
 * longs.sql
 * monitsegs[s].sql
 * nls.sql
 * obj.sql
 * parseas.sql
 * privobj.sql
 * privuser[d].sql
 * recursos.sql
 * redosec.sql
 * resumable.sql
 * sched.sql
 * sessionwaits.sql
 * sesstat.sql
 * showplan.sql
 * showsga[c].sql
 * sort.sql
 * stragg.sql
 * tops[a|ab|b|k].sql
 * triggers.sql
 
## Installation

* Clone the repo or download the zip file;
* Extract the files;
* Point SQLPATH variable to the folder containing the scripts.

## Todo

 - Add Code Comments
 - Write a reference guide for the scripts
 - Replace SQL\*Plus's format commands

License
----

GNU GENERAL PUBLIC LICENSE, Version 2

**Free Software, Hell Yeah!**
