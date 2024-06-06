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

select * from history_purchase_cus('987654321')



























