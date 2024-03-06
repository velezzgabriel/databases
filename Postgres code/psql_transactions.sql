---------------------------------   TRANSACTIONS
-- Group of commands that change the data stored in a database. It is treated as a single unit of work. 

---------------------BANK TRANSACTION
--In PostgreSQL, a transaction is set up by surrounding the SQL commands of the transaction with BEGIN and COMMIT commands. 
--Suppose that we want to record a payment of $100.00 from Alice's account to Bob's account. 
--So our banking transaction would actually look like:
BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
UPDATE branches SET balance = balance - 100.00
    WHERE name = (SELECT branch_name FROM accounts WHERE name = 'Alice');
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
UPDATE branches SET balance = balance + 100.00
    WHERE name = (SELECT branch_name FROM accounts WHERE name = 'Bob');
COMMIT;

------------------------------- SAVEPOINT
--Savepoints allow you to selectively discard parts of the transaction, while committing the rest. 
--After defining a savepoint with SAVEPOINT, you can if needed roll back to the savepoint with ROLLBACK TO. 
--All the transaction's database changes between defining the savepoint and rolling back to it are discarded, but changes earlier than the savepoint are kept.

--After rolling back to a savepoint, it continues to be defined, so you can roll back to it several times. Conversely, if you are sure you won't need to roll back to a particular savepoint again, it can be released, so the system can free some resources. 
--Keep in mind that either releasing or rolling back to a savepoint will automatically release all savepoints that were defined after it.



"
Transactions with correctness criteria as ACID properties:

-Atomicity: All actions in txn happen, or none happen. All or nothing.
            To ensure it:
            *Logging(common): DBMS logs all actions so that it can undo actions of aborted transactions
                      Maintain undo records both in memory and on disk.
            *Shadow paging: DBMS makes copies of pages and txns make changes to those copies. Only when the txn commits is the page made visible to others.


-Consitency: If each txn is consistent and the db starts consistent, then it ends up consistent. It looks correct to me.
            *DB Consistency
            *Transaction Consistency

-Isolation: Execution of one txn is isolated from that of other txns. All by myself.
            Each txn executes as if it was running by itself.
            DBMS achieves concurrency by interleaving the actions(reads/writes of DB objects) of txns.
            We need a way to interleave txns but still make it appear as if they ran one at a time.
        *isolation levels:
            -read uncommited: no isolation, any change from the outside is visible to the transaction.
            -read commited: each query in a transaction only sees committed stuff.
            -repeatable read: each query in a transaction only sees committed updates at the beginning of the transaction. 
            -serializable: transactions are serialized.


-Durability: If a txn commits, its effects persist. I will survive.


INTERLEAVED EXECUTION ANOMALIES
*Read-Write conflicts: Unrepeatable Read -> Txn gets different values when reading the same object multiple times.
*Write-Read conflicts: Dirty Read -> One txn reads data written by another txn that has not committed yet.
*Write-Write conflicts: Lost Update -> One txn overwrites uncommitted data from another uncommitted txn.
"



------------------------- CONCURRENCY PROBLEMS -----------------
/*
Lost Updates:
This occurs when two or more transactions attempt to update the same data simultaneously, and one of the updates is lost because it gets overwritten by another.

Dirty Reads:
A dirty read occurs when one transaction reads data that has been modified but not yet committed by another transaction.
This can result in a transaction basing decisions on data that may be rolled back later, leading to incorrect results or actions.

Non-Repeatable Reads:
Non-repeatable reads happen when a transaction reads the same row multiple times within the same transaction, and the data changes between reads.
This can lead to inconsistent and unexpected data during the course of a transaction.

Phantom Reads:
Phantom reads occur when a transaction reads a set of rows that satisfy a certain condition, but another transaction inserts or deletes rows that would have met the same condition.
This can result in unexpected data appearing or disappearing during the transaction.
*/


--------------------------- concurrency problems MITIGATION
/*
PostgreSQL provides mechanisms to address these concurrency problems:

Isolation Levels:
PostgreSQL supports different isolation levels 
(e.g., Read Uncommitted, Read Committed, Repeatable Read, Serializable), which control the level of visibility and locking during transactions.

Locking:
PostgreSQL uses various locking mechanisms, such as row-level locks, table-level locks, and deadlock detection, to manage concurrent access to data. 
Locks help prevent conflicting operations by allowing only one transaction to modify data at a time.

MVCC (Multi-Version Concurrency Control):
PostgreSQL employs MVCC to allow multiple transactions to read and write data concurrently without blocking each other. 
MVCC maintains multiple versions of data, ensuring that each transaction sees a consistent snapshot of the database at a specific point in time.

Explicit Locking:
PostgreSQL allows you to use explicit locking statements like SELECT ... FOR UPDATE and SELECT ... FOR SHARE to control access to specific rows or tables, 
providing fine-grained control over concurrency.
*/




------------------------------- LOCKS in postgres
/*
AccessShareLock (SELECT):
This is the least restrictive lock level.
Multiple transactions can hold AccessShareLock on the same resource simultaneously.
It's used for read-only operations like SELECT.

RowShareLock (SELECT FOR UPDATE/SHARE):
Multiple transactions can hold RowShareLock on the same resource simultaneously.
It's used when a transaction wants to read a row while indicating an intention to update it (SELECT FOR UPDATE) or when multiple transactions want to read a row without locking each other out (SELECT FOR SHARE).

RowExclusiveLock (INSERT, UPDATE, DELETE):
Only one transaction can hold a RowExclusiveLock on a resource at a time.
It's used for operations that modify rows (INSERT, UPDATE, DELETE) to prevent concurrent updates.

ShareUpdateExclusiveLock (VACUUM FULL, ANALYZE):
Multiple transactions can hold ShareUpdateExclusiveLock on the same resource simultaneously.
It's used for VACUUM FULL and ANALYZE operations to prevent other transactions from altering the table structure while these operations are in progress.

ShareLock (DML statements):
Multiple transactions can hold ShareLock on the same resource simultaneously.
It's used for some DML (Data Manipulation Language) operations to prevent concurrent schema changes.

ShareRowExclusiveLock (TRUNCATE):
Multiple transactions can hold ShareRowExclusiveLock on the same resource simultaneously.
It's used for TRUNCATE operations to prevent concurrent schema changes.

ExclusiveLock (DDL statements):
Only one transaction can hold an ExclusiveLock on a resource at a time.
It's used for DDL (Data Definition Language) operations like ALTER TABLE to prevent concurrent schema changes.

AccessExclusiveLock (DROP, CREATE, ALTER):
Only one transaction can hold an AccessExclusiveLock on a resource at a time.
It's used for DDL operations that significantly affect the table structure, such as DROP, CREATE, and ALTER TABLE.
*/



--------------------------------- ISOLATION levels
/*
These isolation levels can be set using the SET TRANSACTION ISOLATION LEVEL statement or specified at the beginning of a transaction:
--> SET TRANSACTION ISOLATION LEVEL isolation_level;


Here are the four standard isolation levels in PostgreSQL:

Read Uncommitted (ISOLATION LEVEL READ UNCOMMITTED):
In this isolation level, transactions can read uncommitted changes made by other transactions.
It provides the highest level of concurrency but offers no guarantees about data consistency or integrity.
Dirty reads, non-repeatable reads, and phantom reads are possible.
This is the least restrictive isolation level but is rarely used in practice due to its potential for data anomalies.

Read Committed (ISOLATION LEVEL READ COMMITTED):
In Read Committed isolation, transactions can only read committed data.
It avoids dirty reads by ensuring that a transaction sees only committed changes made by other transactions.
However, non-repeatable reads and phantom reads are still possible since other transactions can commit changes while a transaction is in progress.

Repeatable Read (ISOLATION LEVEL REPEATABLE READ):
In this isolation level, a transaction sees a consistent snapshot of the data as of the start of the transaction.
It prevents dirty reads, non-repeatable reads, and phantom reads.
However, it doesn't prevent other transactions from inserting new rows, so if a transaction repeats a query, it might see new rows created by other transactions.

Serializable (ISOLATION LEVEL SERIALIZABLE):
Serializable is the strictest isolation level.
It guarantees that transactions behave as if they are executing one after the other in a serial manner, even though they may run concurrently.
This level ensures full data consistency and integrity but can lead to more contention and lower concurrency.
Serializable isolation uses row-level locks and can result in deadlock situations, which require careful handling.
*/






--begin transaction or begin
--commit
--rollback

--savepoint
--rollback to savepoint
--release savepoint

--locking

--drop table 
--truncate table



--********************************   Bank Transaction Excercise
---------RETURN VARIABLE option
CREATE OR REPLACE FUNCTION transactions_RETURN (from_account int, amount numeric, to_account int)
RETURNS varchar(50)
LANGUAGE plpgsql
AS $$
DECLARE
	variable varchar(50);
BEGIN
    -- Check if both accounts exist
    IF EXISTS (SELECT 1 FROM accounts WHERE id = from_account) THEN
        IF EXISTS (SELECT 1 FROM accounts WHERE id = to_account) THEN
            -- Check if the balance in the from_account is sufficient
            IF (SELECT balance FROM accounts WHERE id = from_account) >= amount THEN
                -- Perform the transaction
                UPDATE accounts SET balance = balance - amount WHERE id = from_account;
                UPDATE accounts SET balance = balance + amount WHERE id = to_account;
                variable := 'Transaction successful';
                RETURN variable;
            ELSE 
                variable := 'Funds insufficient';
                RETURN variable;
            END IF;
        ELSE
            variable := '"to_account" ID not found';
            RETURN variable;
        END IF;
    ELSE
		variable := '"from_account" ID not found';
        RETURN variable;
    END IF;
END;
$$;


---------- RAISE NOTICE option
CREATE OR REPLACE FUNCTION transactions_NOTICE(from_account int, amount numeric, to_account int)
RETURNS varchar(50)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if both accounts exist
    IF EXISTS (SELECT 1 FROM accounts WHERE id = from_account) THEN
        IF EXISTS (SELECT 1 FROM accounts WHERE id = to_account) THEN
            -- Check if the balance in the from_account is sufficient
            IF (SELECT balance FROM accounts WHERE id = from_account) >= amount THEN
                -- Perform the transaction
                UPDATE accounts SET balance = balance - amount WHERE id = from_account;
                UPDATE accounts SET balance = balance + amount WHERE id = to_account;
                RAISE NOTICE 'Transaction successful';
            ELSE 
                RAISE NOTICE 'Funds insufficient';
            END IF;
        ELSE
            RAISE NOTICE '"to_account" ID not found';
        END IF;
    ELSE
		RAISE NOTICE '"from_account" ID not found';
    END IF;
END;
$$;



------------ RAISE EXCEPTION 
CREATE OR REPLACE FUNCTION transactions_EXCEPTION(from_account int, amount numeric, to_account int)
RETURNS varchar(50)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if both accounts exist
    IF EXISTS (SELECT 1 FROM accounts WHERE id = from_account) THEN
        IF EXISTS (SELECT 1 FROM accounts WHERE id = to_account) THEN
            -- Check if the balance in the from_account is sufficient
            IF (SELECT balance FROM accounts WHERE id = from_account) >= amount THEN
                -- Perform the transaction
                UPDATE accounts SET balance = balance - amount WHERE id = from_account;
                UPDATE accounts SET balance = balance + amount WHERE id = to_account;
                RAISE NOTICE 'Transaction successful';
            ELSE 
                RAISE EXCEPTION 'Funds insufficient';
            END IF;
        ELSE
            RAISE EXCEPTION '"to_account" ID not found';
        END IF;
    ELSE
		RAISE EXCEPTION '"from_account" ID not found';
    END IF;
END;
$$;






-------------------------------------------
------------------ DO block ------------------

DO $$
DECLARE
    from_account int := 1; 
    amount int := 50; 
    to_acount int := 2;
BEGIN
    
    -- Check if both accounts exist
    IF EXISTS (SELECT 1 FROM accounts WHERE id = from_account) THEN
        IF EXISTS (SELECT 1 FROM accounts WHERE id = to_account) THEN
            -- Check if the balance in the from_account is sufficient
            IF (SELECT balance FROM accounts WHERE id = from_account) >= amount THEN
                -- Perform the transaction
                UPDATE accounts SET balance = balance - amount WHERE id = from_account;
                UPDATE accounts SET balance = balance + amount WHERE id = to_account;
                RAISE NOTICE 'Transaction successful';
            ELSE 
                RAISE EXCEPTION 'Funds insufficient';
            END IF;
        ELSE
            RAISE EXCEPTION '"to_account" ID not found';
        END IF;
    ELSE
		RAISE EXCEPTION '"from_account" ID not found';
    END IF;
   

    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION 'An error occurred: %', SQLERRM;
            RAISE NOTICE 'An error occurred: %', SQLERRM;
END;
$$;