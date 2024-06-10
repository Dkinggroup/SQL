CREATE OR REPLACE FUNCTION reset_all_scores()
RETURNS VOID AS $$
BEGIN
    UPDATE Account
    SET Score = 0;
END;
$$ LANGUAGE plpgsql;
SELECT reset_all_scores();

CREATE OR REPLACE FUNCTION update_scores()
RETURNS VOID AS $$
BEGIN
    UPDATE Account a
    SET Score = (
        SELECT COALESCE(SUM(f.price * bl.quantity) / 1000, 0)
        FROM Bill_Line bl
        JOIN Bill b ON bl.id_bill = b.id_bill
        JOIN Customer c ON b.id_customer = c.id_customer
        JOIN Food f ON bl.id_food = f.id_food
        WHERE c.phone = a.phone
    );
END;
$$ LANGUAGE plpgsql;

SELECT update_scores();
