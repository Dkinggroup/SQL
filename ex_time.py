import psycopg2
import time
#nhap dbname, user, pass và host vào đây
conn = psycopg2.connect(dbname='0_01_test_fun_1st', user='postgres', password='TT665@ggv', host='localhost') 
cur = conn.cursor()

sql_query = "select * from top10_food()" #chèn câu lệnh định chạy vào đây
num_iterations = 10
total_execution_time = 0

print('Query or Function:')
print(sql_query)
print()

for i in range(num_iterations):
    start_time = time.time()
    cur.execute(sql_query)
    end_time = time.time()
    execution_time = round((end_time - start_time) * 1000, 4)  # Chuyển đổi thời gian thành ms và làm tròn đến 4 chữ số sau dấu "."
    total_execution_time += execution_time
    print("Iteration {}: Execution time: {} ms".format(i + 1, execution_time))

average_execution_time = round(total_execution_time / num_iterations, 4)  # Tính thời gian trung bình và làm tròn đến 4 chữ số sau dấu "."
print("Average execution time: {} ms".format(average_execution_time))

conn.close()
