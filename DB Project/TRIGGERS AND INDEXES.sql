--Updates total sum, final sum and discount in orders
CREATE OR REPLACE FUNCTION update_sums()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    DECLARE
        set_price integer;
        amount integer;
        orderid integer;
        storeid integer;
    BEGIN

        orderid = new.order_id;
        SELECT INTO storeid store_id FROM orders WHERE id = orderid;
        SELECT INTO set_price price FROM inventory
            WHERE inventory.store_id = storeid AND inventory.product_id = new.product_id;
        SELECT INTO amount inventory.quantity FROM inventory
            WHERE inventory.store_id = storeid AND inventory.product_id = new.product_id;


        IF amount - new.quantity < 0 THEN
            RAISE EXCEPTION 'This store does not have such amount of this product';
        end if;


        UPDATE inventory SET quantity = quantity - new.quantity
        WHERE product_id = new.product_id AND store_id = storeid;

        UPDATE orders SET total_sum = total_sum + new.quantity * set_price
        WHERE id = new.order_id;
        UPDATE orders SET final_sum = total_sum
        WHERE id = new.order_id;


        UPDATE store_statistics SET quantity = quantity + new.quantity
            WHERE product_id = new.product_id AND store_id = storeid;


        RETURN NEW;
    END;
    $$;

DROP TRIGGER update_total_sums ON order_items;

CREATE TRIGGER update_total_sums
    AFTER INSERT
    ON order_items
    FOR EACH ROW
    EXECUTE PROCEDURE update_sums();

create or replace procedure discounts()
language plpgsql
as $$
    declare
       new_discount float;
        f record;
    begin
        FOR f in SELECT * FROM orders LOOP
            IF f.total_sum > 50000 THEN
                new_discount = 0.05;
            ELSEIF f.total_sum between 10000 and 50000 THEN
                new_discount = 0.02;
            ELSE new_discount = 0;
            end if;
            UPDATE orders SET final_sum = final_sum - final_sum * new_discount WHERE id = f.id;
            UPDATE orders SET discount = new_discount WHERE id = f.id;
        end loop;
    end;
    $$;

call discounts();

--INDEXES

CREATE INDEX search_customers
ON customers(name);

CREATE INDEX stores_products
ON inventory(store_id);

CREATE INDEX dates
ON online_orders(required_date);

CREATE INDEX search_orders
ON order_items(order_id);

CREATE INDEX search_order_id
ON orders(id);

CREATE INDEX search_products
ON products(name);

CREATE INDEX search_statistics
ON store_statistics(store_id);

