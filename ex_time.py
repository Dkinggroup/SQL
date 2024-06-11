import psycopg2
import time

# Nhập dbname, user, pass và host vào đây
conn = psycopg2.connect(dbname='test_fun_1st', user='postgres', password='TT665@ggv', host='localhost') 
cur = conn.cursor()

sql_query = "select sum_day('2024-04-10') "  # Chèn câu lệnh định chạy vào đây
num_iterations = 11
total_execution_time = 0

print('Query or Function:')
print(sql_query)
print()

for i in range(1, num_iterations + 1):  # Bắt đầu từ lần thứ 2 đến lần thứ 11
    start_time = time.time()
    cur.execute(sql_query)
    end_time = time.time()
    execution_time = round((end_time - start_time) * 1000, 4)  # Chuyển đổi thời gian thành ms và làm tròn đến 4 chữ số sau dấu "."
    total_execution_time += execution_time
    if i > 1: print("Iteration {}: Execution time: {} ms".format(i, execution_time))

average_execution_time = round(total_execution_time / num_iterations, 4)  # Tính thời gian trung bình và làm tròn đến 4 chữ số sau dấu "."
print("Average execution time: {} ms".format(average_execution_time))

conn.close()
