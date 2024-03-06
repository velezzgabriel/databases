----------------------- ------NORMALIZATION-----------------------------------------
"
******************************* NORMAL FORMS ***************************************
1st to 6th Normal Forms, BCNF (Boyce-Codd Normal Form):
Not being normalized makes you incur in:
----> disk space wastage
----> data inconsistency
----> DML queries become slow. 



------------------------------------KEYS
SUPER KEYs:  All single columns or combination of columns that can uniquely identify a row in a  table.

CANDIDATE KEYs: Minimal set of superkeys that can uniquely identify a row in a table. Hence we could choose from any of the candidates keys to be Pkey. 
            If a superkey is composed of other smaller superkeys, that parent superkey cannot be a candidate key. 

PRIME ATTRIBUTE: An attribute (column) in a relation (table) that is part of a candidate key for that relation. 

PRIMARY KEY: The candidate key chosen to uniquely identify each row of data in a table. 
            PKey must be unique and not null. every row must have a  pkey. 

ALTERNATE KEYs: All candidate keys that have not been chosen as primary key. 

FOREIGN KEYs: It is an attribute in a table that is used to define its relationship with another table.
                Foreign keys help maintaining integrity for tables in relationship.

COMPOSITE KEYs: ANY key with more than one attribute. 

COMPOUND KEYs: it is a composite key that has at least one attribute which is a Foreign key. 

SURROGATE KEY: If a table has no attribute that can be used to identify the data, we create an attribute for this purpose. 
                It adds no meaning to the data but serves the sole purpose of identifying rows uniquely in a table. 


 ------------------------- GLOSARY ---------------------
***candidate key : Set of columns which uniquely identify a record.
                    A table can have multiple candidate keys because there can be multiple set of columns which uniquely identify a record/row  in a table.

***non-key columns: Columns which are not part of the candidate key or primary key. 

***partial dependency:  If your candidate key is a combination of 2 columns (or multiple columns) then every non-key column should be fully dependent on all the columns.
                        If there is any non-key column which depends only on one of the candidate key columns then this results in partial dependency.

***transitive dependency:   Lets say you have a table T which has 3 columns A,B,C.
                            If A is funcionally dependent on B and B is functionally dependent on C then we can say that A is functionally dependen on C.


-----------------------------------1st Normal Form:
--> every column or attribute need to have a single value (dont be multivalued columns)
--> data in each column should be atomic, meaning...No multiple values
--> must NOT contain COMPOSITE ATTRIBUTES, which are the ones that can be further divided into parts. 
        e.g. Name:first_name, middle_name,last_name.     Address: number, street, neighbourhood, postcode.
--> be able to uniquely identify every single row. Either through a single or multiple columns. Not mandatory to have primary key.
*************Decomplexify:
--> using row order to convey information is not permitted
-->mixing data types within the same column is not permitted
-->having a table without a primary key is not permitted
--> table does not contain any repeating column groups
--> repeating groups are not permitted


-----------------------------------2nd Normal Form:
--> must be in 1stNF
--> each non-key attribute in the table must be dependent on the entire primary key. 
--> all non-key attributes must be fully dependent on candidate key.
    e.g. if a non-key column is partially dependent on candidate key (subset of columns forming candidate key) then split them into separate tables.
--> every table should have primary key and relationship between the tables should be formed using foreign key.

*************Kudvenkat:
--> move redundant data to a separate table


-----------------------------------3rd Normal Form:  
-->must be in 2ndNF
-->avoid transitive dependencies
-->  each non-key attribute in the table must depend on the key, the whole key and nothing but the key.


-----------------------------------Boyce-Codd Normal Form (BCNF)
-->It is a slightly stronger version of 3rd normal form. Differences between these two are subtle. 
Decomplexify: each attribute in the table must depend on the key, the whole key and nothing but the key.


-----------------------------------4th Normal Form:
Decomplexify: the only kinds of multivalued dependency allowed in a table are multivalued dependencies on the key.
            Multivalued dependencies in a table must be multivalued dependencies on the key.
--> remember the example of the bird houses. he had to split the key into two tables, one being Model-Color and another one being Model-Style. 

-----------------------------------5th Normal Form:
Decomplexify: it must not be possible to describe the talbe as being the logical result of joining some other tables together.
             The table (which must be in 4th normal form) cannot be descriable as the logical result of joining some other talbes together.
--> remember the example of the ice-cream preferences which end up being split in three tables: Brand-Flavor, Person-Brand and Person-Flavor.




"