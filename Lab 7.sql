--Task 1
--Large objects are stored as blob or clob

--Task 2

CREATE ROLE accountant;
CREATE ROLE administrator CREATEROLE;
CREATE ROLE support;
GRANT SELECT ON accounts TO accountant;
GRANT SELECT, INSERT, UPDATE ON transactions TO accountant;
GRANT ALL ON transactions, accounts, customers TO administrator;
GRANT SELECT, INSERT, UPDATE ON accounts, customers TO support;

CREATE USER Sasha;
CREATE USER Diana;
CREATE USER Kate;
GRANT administrator TO Sasha;
GRANT accountant to Diana WITH ADMIN OPTION;
GRANT support to Kate;

REVOKE UPDATE ON customers FROM Kate;
REVOKE UPDATE ON transactions FROM Diana;

--Task 3

--

ALTER TABLE accounts ALTER COLUMN currency SET NOT NULL;

--Task 5

CREATE UNIQUE INDEX unique_currency ON accounts (account_id, currency);

CREATE INDEX cur_balance ON accounts (currency, balance);

--Task 6

ALTER TABLE accounts ADD CONSTRAINT balance_more_than_limit CHECK (balance >= accounts.limit);

BEGIN;
INSERT INTO transactions VALUES (4, now(), 'RS88012', 'NT10204', 4000, 'init');
SAVEPOINT savepoint1;

do $$
begin

    UPDATE accounts SET
    balance = balance + 4000 WHERE account_id = 'RS88012';
    UPDATE accounts SET
    balance = balance - 4000 WHERE account_id = 'NT10204';
    UPDATE transactions SET
    status = 'commited' WHERE id = 4;

exception when others then

    UPDATE transactions SET
    status = 'rollback' WHERE id = 4;
    raise notice 'Rollbacked';


end; $$
language 'plpgsql';

COMMIT;
