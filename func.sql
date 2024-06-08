--reset serial
ALTER SEQUENCE category_id_category_seq RESTART WITH 1;
ALTER SEQUENCE food_id_food_seq RESTART WITH 1;
ALTER SEQUENCE customer_id_customer_seq RESTART WITH 1;
ALTER SEQUENCE bill_id_bill_seq RESTART WITH 1;
ALTER SEQUENCE bill_line_id_bill_line_seq RESTART WITH 1;
ALTER SEQUENCE table_order_id_table_seq RESTART WITH 1;
ALTER SEQUENCE employee_id_employee_seq RESTART WITH 1;
ALTER SEQUENCE shift_id_shift_seq RESTART WITH 1;


--Top 10 khách hàng mua từ trước đến hiện tại (chỉ tính tạo acc)
create or replace function top10_cus()
returns table(
	Name varchar(50),
	score int
) as $$
begin 
	return query
	select c.name_customer as Name, a.score as score
	from account a left join customer c on a.phone = c.phone
	order by a.score desc
	limit 10;
end;
$$ language plpgsql;

select * from top10_cus()
----------------------------------------------------------------------------------------------
--Lich su mua hang cua cus
create or replace function history_purchase_cus(in phonee varchar)
returns table(
	Date_Order date,
	Food_Name varchar(100),
	Quantity int
) as $$
begin
	return query
	select b.date_order as Date_Order, 
			f.name_food as Food_Name,
			bl.quantity as Quantity
	from customer c
		right join account a on a.phone = c.phone
		join bill b on c.id_customer = b.id_customer
		join bill_line bl on b.id_bill = bl.id_bill
		join food f on bl.id_food = f.id_food
	where a.phone = phonee
	order by b.date_order;
end;
$$ language plpgsql;

DROP FUNCTION history_purchase_cus(character varying)

select * from history_purchase_cus('123456789')
----------------------------------------------------------------------------------------------
--top 10 loại thức ăn bán được từ trước đến nay
create or replace function top10_food()
returns table(
	Food_Name varchar(100),
	Quantity int
) as $$
begin
	return query
	select f.name_food as Food_Name,
			sum(bl.quantity)::int as Quantity
	from bill_line bl
	join food f on bl.id_food = f.id_food
	group by f.name_food
	order by sum(bl.quantity) desc;	
end;
$$ language plpgsql;

DROP FUNCTION top10_food()

select * from top10_food()

----------------------------------------------------------------------------------------------
--tinh truoc gia tien cho khach hang(ap dung discout khi co tai khoan)

create or replace function pre_price(in bill_id_in int)
returns table (
	bill_id int,
	total_price float
) as $$
begin
	return query
	select bl.id_bill as bill_id,
	--chia truong hop gia tien
		round( case 
		   		when a.score > 3000 then sum(f.price * bl.quantity)*0.80
  				when a.score > 1050 then sum(f.price * bl.quantity)*0.85
				when a.score > 600 then sum(f.price * bl.quantity)*0.90
				when a.score > 300 then sum(f.price * bl.quantity)*0.95
		  		else sum(f.price * bl.quantity) 
		   end 
		   ) as total_price
	--ket thuc chia gia tien
	from bill_line bl
	join food f on bl.id_food = f.id_food
	join bill b on bl.id_bill = b.id_bill
	join customer c on b.id_customer = c.id_customer
	left join account a on c.phone = a.phone
	where bl.id_bill = bill_id_in
	group by bl.id_bill, a.score;
end;
$$ language plpgsql;

DROP FUNCTION pre_price(integer)

select * from pre_price(1)
----------------------------------------------------------------------------------------------
--rec mon dua tren so thich???? -> top 5 mua nhieu nhat cua khach
create or replace function top5_food_cus(in cus_phone varchar)
returns table(
	food_name varchar(100),
	total_quan bigint
)	as $$
begin
	return query
	select f.name_food, sum(bl.quantity) astotal_quan
	from food f
	join bill_line bl on f.id_food = bl.id_food
	join bill b on bl.id_bill = b.id_bill
	join customer c on b.id_customer = c.id_customer
	where c.phone = cus_phone
	group by f.name_food
	order by sum(bl.quantity) desc
	limit 5;
end;
$$ language plpgsql;

DROP FUNCTION top5_food_cus(varchar)

select * from top5_food_cus('123456789')
