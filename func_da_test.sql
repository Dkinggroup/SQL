😊--Thêm category
CREATE OR REPLACE FUNCTION AddCategory(
    p_Name_Category VARCHAR(100)
) RETURNS VOID AS $$
BEGIN
    -- Kiểm tra xem Name_Category có tồn tại hay không
    IF EXISTS (SELECT 1 FROM Category WHERE Name_Category = p_Name_Category) THEN
        RAISE EXCEPTION 'Category name already exists';
    ELSE
        INSERT INTO Category (Name_Category)
        VALUES (p_Name_Category);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT AddCategory('Test_cate');
--cf test ok
------------------------------------------------------------------------------------------------------------------------
😊-- Thêm food
CREATE OR REPLACE FUNCTION AddFood(
    p_Name_Food VARCHAR(100),
    p_Price REAL,
    p_ID_Category INT
) RETURNS VOID AS $$
BEGIN
    -- Kiểm tra xem ID_Category có tồn tại hay không
    IF NOT EXISTS (SELECT 1 FROM Category WHERE ID_Category = p_ID_Category) THEN
        RAISE EXCEPTION 'Category ID does not exist';
    ELSE
        INSERT INTO Food (Name_Food, Price, ID_Category)
        VALUES (p_Name_Food, p_Price, p_ID_Category);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT AddFood('Test_Food', 100000, 10);
--cf test ok
------------------------------------------------------------------------------------------------------------------------
😊-- Thêm nhân viên 
CREATE OR REPLACE FUNCTION AddEmployee(
    p_Name_Employee VARCHAR(50),
    p_Phone VARCHAR(16),
    p_Email VARCHAR(50),
    p_CCCD VARCHAR(50)
) RETURNS VOID AS $$
BEGIN
    -- Kiểm tra xem CCCD có tồn tại hay không
    IF EXISTS (SELECT 1 FROM Employee WHERE CCCD = p_CCCD) THEN
        RAISE EXCEPTION 'CCCD already exists';
    ELSE
        INSERT INTO Employee (Name_Employee, Phone, Email, CCCD)
        VALUES (p_Name_Employee, p_Phone, p_Email, p_CCCD);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT AddEmployee('Test_em', '0000000001', 'test@example.com', 'CCCD00001');
--cf test ok
------------------------------------------------------------------------------------------------------------------------
-- Thêm ca vào bảng Shift
CREATE OR REPLACE FUNCTION AddShiftsForDay(
    p_Date_Shift DATE
) RETURNS VOID AS $$
BEGIN
    -- Thêm ca làm việc lúc 7h
    INSERT INTO Shift (Date_Shift, Time_Shift)
    VALUES (p_Date_Shift, '07:00:00');

    -- Thêm ca làm việc lúc 12h
    INSERT INTO Shift (Date_Shift, Time_Shift)
    VALUES (p_Date_Shift, '12:00:00');

    -- Thêm ca làm việc lúc 17h
    INSERT INTO Shift (Date_Shift, Time_Shift)
    VALUES (p_Date_Shift, '17:00:00');
END;
$$ LANGUAGE plpgsql;

SELECT AddShiftsForDay('2024-06-07');
--k ro co dung func nay k????
------------------------------------------------------------------------------------------------------------------------
😊-- Thêm customer + bill
CREATE OR REPLACE FUNCTION add_customer_and_bill(
    p_name VARCHAR,
    p_phone VARCHAR,
    p_status BOOLEAN,
    p_date_order DATE,
    p_time_order TIME
) RETURNS VOID AS $$
DECLARE
    v_id_customer INT;
BEGIN
    -- Kiem tra xem sdt da ton tai hay chua
    SELECT ID_Customer INTO v_id_customer
    FROM Customer
    WHERE Phone = p_phone;
    -- Chua ton tai, them customer moi
    IF NOT FOUND THEN
        INSERT INTO Customer (Name_Customer, Phone, status)
        VALUES (p_name, p_phone, p_status)
        RETURNING ID_Customer INTO v_id_customer;
    END IF;
    -- Chen bill
    INSERT INTO Bill (Status_Bill, Date_Order, Time_Order, ID_Customer)
    VALUES (false, p_date_order, p_time_order, v_id_customer);
END;
$$ LANGUAGE plpgsql;

select from add_customer_and_bill(
	'test_cus',
	'0000000011',
	true,
	'3333-3-3',
	'03:03:03'
)
--cf test ok
------------------------------------------------------------------------------------------------------------------------
😊-- Tạo Account nếu có nhu cầu 
CREATE OR REPLACE FUNCTION AddAccount(
    p_Customer_Phone VARCHAR(16)
) RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Account WHERE Phone = p_Customer_Phone) THEN
        -- Nếu không tồn tại, thêm tài khoản mới
        INSERT INTO Account (phone, score)
        VALUES (p_Customer_Phone, 0);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT AddAccount('0000000011');
--cf test ok
------------------------------------------------------------------------------------------------------------------------
😊-- Add Bill Line
CREATE OR REPLACE FUNCTION add_bill_line(
    p_Items INT[][],
    p_Item_Count INT
)
RETURNS VOID AS $$
DECLARE
    idd INT;
    i INT;
BEGIN
    SELECT MAX(ID_Bill) INTO idd FROM Bill;
    -- Khai báo cursor để lặp qua các hàng của bảng Bill và lấy ID_Bill lớn nhất
    FOR idd IN SELECT MAX(ID_Bill) FROM bill LOOP
        -- Thêm các món ăn vào bảng bill_line với ID_Bill mới nhất
        FOR i IN 1..p_Item_Count LOOP
            INSERT INTO bill_line (ID_Bill, ID_Food, Quantity) 
            VALUES (idd, p_Items[i][1], p_Items[i][2]);
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT add_bill_line(
    ARRAY[[1, 1], [2, 1]],  -- Mang co dac diem [id mon 1, so luong mon 1], [id mon 2, so luong mon 2]
    2                        -- Số lượng món ăn trong mảng
);
--cf test ok
------------------------------------------------------------------------------------------------------------------------
😊-- Chỉnh sửa số lượng món trong bill_line
CREATE OR REPLACE FUNCTION modify_bill_line(
    p_bill_id INT,
    p_food_id INT,
    p_quantity_change INT --day la so luong them hoac bot
)
RETURNS VOID AS $$
DECLARE 
    tmp_quantity INT;
BEGIN
    -- Kiểm tra xem món đã tồn tại trong hóa đơn chưa
    SELECT Quantity INTO tmp_quantity
    FROM Bill_Line
    WHERE ID_Bill = p_bill_id AND ID_Food = p_food_id;

    -- Nếu món chưa tồn tại, thêm món vào bảng Bill_Line với số lượng mới
    IF NOT FOUND THEN
        INSERT INTO Bill_Line (ID_Bill, ID_Food, Quantity)
        VALUES (p_bill_id, p_food_id, p_quantity_change);
    ELSE
        -- Tính toán số lượng mới sau khi thêm/bớt
        tmp_quantity := tmp_quantity + p_quantity_change;

        -- Cập nhật số lượng mới vào bảng Bill_Line
        UPDATE Bill_Line
        SET Quantity = tmp_quantity
        WHERE ID_Bill = p_bill_id AND ID_Food = p_food_id;

        -- Kiểm tra nếu số lượng mới bằng 0, thì xóa món khỏi hóa đơn
        IF tmp_quantity = 0 THEN
            DELETE FROM Bill_Line
            WHERE ID_Bill = p_bill_id AND ID_Food = p_food_id;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT modify_bill_line(10001, 1, 1); --them 1 so luong o mon 1
--cf test ok
------------------------------------------------------------------------------------------------------------------------
😊-- Set trạng thái bàn thành đã có người dùng

CREATE OR REPLACE FUNCTION Update_table(ID_TableAdd INT)
RETURNS VOID AS $$
DECLARE get_newBillID INT;
BEGIN
    SELECT MAX(ID_Bill) INTO get_newBillID FROM Bill;

	
    UPDATE Table_
	SET status = true , ID_Bill = get_newBillID
	WHERE ID_Table = ID_TableAdd AND status = false;
END;
$$ LANGUAGE plpgsql;

SELECT Update_table(1);
--cf test ok
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--add shift (query)
INSERT INTO Shift (Date_Shift, Start_Time, End_Time)
VALUES ('2024-06-10', '09:00:00', '16:00:00'), --id 1
	   ('2024-06-10', '16:00:00', '23:00:00');
--------------------------------------------------
😊--Update Shift
CREATE OR REPLACE FUNCTION update_shift(shift_id INT, start_time_new TIME, end_time_new TIME)
RETURNS VOID AS $$
BEGIN
    UPDATE Shift
    SET Start_Time = start_time_new, End_Time = end_time_new
    WHERE ID_Shift = shift_id;
END;
$$ LANGUAGE plpgsql;

select update_shift(1,'09:30:00','16:00:00')
--cf test ok
------------------------------------------------------------------------------------------------------------------------
😊--Update schedule

CREATE OR REPLACE FUNCTION add_emp_sche(
    shift_id INT,
    employee_names TEXT[],
    num_employees INT
) RETURNS VOID AS $$
DECLARE
    emp_name TEXT;
    emp_id INT;
    counter INT := 0;
BEGIN
    FOREACH emp_name IN ARRAY employee_names
    LOOP
        -- Kiểm tra số lượng nhân viên đã đạt yêu cầu chưa
        IF counter >= num_employees THEN
            EXIT;
        END IF;
        -- Kiểm tra nhân viên có tồn tại không
        SELECT ID_Employee INTO emp_id
        FROM Employee
        WHERE Name_Employee = emp_name;
        -- Nếu nhân viên không tồn tại, error
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Khong tim thay nhan vien %', emp_name;
        END IF;
        -- Thêm vào bảng Schedule
        INSERT INTO Schedule (ID_Shift, ID_Employee)
        VALUES (shift_id, emp_id);
        -- Tăng biến đếm
        counter := counter + 1;
    END LOOP; 
    -- Nếu số lượng nhân viên trong danh sách không đủ
    IF counter < num_employees THEN
        RAISE NOTICE 'Chi co % nhan vien duoc them vao %', counter, num_employees;
    END IF;
END;
$$ LANGUAGE plpgsql;

select add_emp_sche(
	1,
	array['Daniel Chang', 'Catherine Goodwin'],
	2
)
--cf test ok
------------------------------------------------------------------------------------------------------------------------
😊--Delete employee khi k co ca trong schedule	

CREATE OR REPLACE FUNCTION delete_employee(
    emp_name VARCHAR
) RETURNS VOID AS $$
BEGIN
    DELETE FROM Employee
    WHERE Name_Employee = emp_name
    AND NOT EXISTS (
        SELECT 1
        FROM Schedule
        WHERE ID_Employee = Employee.ID_Employee
    );
END;
$$ LANGUAGE plpgsql;

select from delete_employee('Daniel Chang')
--cf test of
------------------------------------------------------------------------------------------------------------------------
😊--Thêm 1 ngày vào date shift

CREATE OR REPLACE FUNCTION shift_date()
RETURNS VOID AS $$
DECLARE
    c_cursor CURSOR FOR SELECT Date_Shift FROM Shift;
    ca RECORD;
    new_date DATE;
BEGIN
    OPEN c_cursor;
    
    LOOP
        FETCH c_cursor INTO ca;
        EXIT WHEN NOT FOUND;
        
        new_date := ca.Date_Shift + INTERVAL '1 day';
        
        UPDATE Shift
        SET Date_Shift = new_date
        WHERE CURRENT OF c_cursor;
    END LOOP;
    
    CLOSE c_cursor;
END;
$$ LANGUAGE plpgsql;

select from shift_date()
--cf test ok
------------------------------------------------------------------------------------------------------------------------
😊--Tổng doanh thu ngày

CREATE OR REPLACE FUNCTION sum_day(p_date DATE)
RETURNS float AS $$
DECLARE
    daily_revenue float;
BEGIN
    SELECT SUM(bl.quantity * f.price)
    INTO daily_revenue
    FROM Bill b
    JOIN Bill_Line bl ON b.ID_Bill = bl.ID_Bill
    JOIN Food f ON bl.ID_Food = f.ID_Food
    WHERE b.Date_Order = p_date
	AND b.status_bill = 'true';

    RETURN daily_revenue;
END;
$$ LANGUAGE plpgsql;

select sum_day('2024-01-01') 
--cf test ok
------------------------------------------------------------------------------------------------------------------------
--Tổng doanh thu tuần (vut)

-- CREATE OR REPLACE FUNCTION doanh_thu_tuan()
-- RETURNS TABLE (tuan TIMESTAMP WITH TIME ZONE, doanh_thu NUMERIC) AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT DATE_TRUNC('week', Date_Order) AS tuan, SUM(tinh_tong_tien_hoa_don(ID_Bill)) AS doanh_thu
--     FROM Bill
--     WHERE status_bill = 'true'
--     GROUP BY DATE_TRUNC('week', Date_Order)
--     ORDER BY tuan;
-- END;
-- $$ LANGUAGE plpgsql;

-- select doanh_thu_tuan()
------------------------------------------------------------------------------------------------------------------------
😊--Tổng doanh thu tháng

CREATE OR REPLACE FUNCTION sum_month(p_month INT, p_year INT)
RETURNS NUMERIC AS $$
DECLARE
    monthly_revenue NUMERIC;
BEGIN
    SELECT SUM(bl.quantity * f.price)
    INTO monthly_revenue
    FROM Bill b
    JOIN Bill_Line bl ON b.ID_Bill = bl.ID_Bill
    JOIN Food f ON bl.ID_Food = f.ID_Food
    WHERE EXTRACT(MONTH FROM b.Date_Order) = p_month
    AND EXTRACT(YEAR FROM b.Date_Order) = p_year
    AND b.status_bill = 'true';

    RETURN monthly_revenue;
END;
$$ LANGUAGE plpgsql;

select sum_month(1, 2024)
--cf test ok
------------------------------------------------------------------------------------------------------------------------
--Tổng số giờ làm của 1 nhân viên trong 1 khoảng thời gian
--cl nay chac del chay dc dau =))))
CREATE OR REPLACE FUNCTION tinh_tong_gio_lam_viec_trong_khoang_thoi_gian(employee_id INT, start_date DATE, end_date DATE)
RETURNS INTERVAL AS $$
DECLARE
    tong_gio INTERVAL := '0 hours';
    ca RECORD;
BEGIN
    FOR ca IN
        SELECT s.Start_Time, s.End_Time
        FROM Schedule sc
        JOIN Shift s ON sc.ID_Shift = s.ID_Shift
        WHERE sc.ID_Employee = id_employee AND s.Date_Shift BETWEEN start_date AND end_date
    LOOP
        tong_gio := tong_gio + (ca.Time_End - ca.Time_Start);
    END LOOP;
    RETURN tong_gio;
END;
$$ LANGUAGE plpgsql;
--chua test
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------














