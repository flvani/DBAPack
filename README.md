# DBA Pack

This set of scripts was written for Oracle SQL\*Plus command line utility. It uses SQL\*Plus's format commands, like PAGESIZE, LINESIZE, FORMAT, PROMPT and so on. Substitution variables are also widely used.

Once you have downloaded the pack, you should extract the files to a folder pointed by SQLPATH environment variable or even place them in the SQL\*Plus's starter folder.

The *login.sql
 * * file is reponsible for several environment sets. You should edit it properly.

## Documentation

### This section intends to be a quick reference guide to the scripts:

Enviroment files

* login.sql - Use this file to format the SQL*Plus's login preferences
```
    Set the OS variable: 
        DEFINE OS=Linux  
        DEFINE OS=Windows.
```

Sql files

 * asm[op].sql - ASM info
 * circuits.sql - Shared conection info
 
 * constraints.sql - List the constraints associated to a table
```
    @constraints <owner> <table> 
        owner - the name of the schema   
        table - the name of table(s) to be queried - can use wild cards
    e.g.
        @constraints USR_TESTE T%
```
 
 * dbafreespace[d].sql - List information about tablespace's free space. For a more detailed report use dbafreespaced.
```
    @dbafreespace <tablespace> 
        tablespace - the name of tablespace(s) to be queried - can use wild cards
    e.g.
        @dbafreespace %
        @dbafreespaced SYSTEM
```
 
 * detalhesql.sql - Report source and exections statistics of a statement
```
    @detalhesql <sql_id> 
        sql_id - SQL identifier. See [tops.sql]
    e.g.
        @detalhesql 62jd0x1sdk42m
```
 * dginst.sql
 * dir.sql - Directory info
 * dpmonit.sql
 * excludes.sql - List avaliable sections for use in expdp/impdp.
 * expplan.sql
 * fknoindex.sql
 * getDDLTablespaces.sql
 * getcursor[d].sql
 * getddl.sql
 * getfontes.sql
 * getpfile.sql
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



