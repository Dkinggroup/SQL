CREATE TABLE Category(
	ID_Category SERIAL PRIMARY KEY,
    Name_Category VARCHAR(100) NOT NULL
);

CREATE TABLE Food(
	ID_Food SERIAL PRIMARY KEY,
	Name_Food  VARCHAR(100) UNiQUE NOT NULL,
	Price REAL NOT NULL,
	ID_Category INT NOT NULL, 
	FOREIGN KEY (ID_Category) REFERENCES Category(ID_Category)
);

CREATE TABLE Customer(
	ID_Customer SERIAL PRIMARY KEY NOT NULL,
	Name_Customer VARCHAR(50) NOT NULL,
	Phone VARCHAR(16) UNIQUE NOT NULL 
);

CREATE TABLE Bill(
	ID_Bill SERIAL PRIMARY KEY, 
	Status_Bill VARCHAR(20) NOT NULL,
	Purchase_Status VARCHAR(20) NOT NULL,
	Date_Order DATE NOT NULL,
	Time_Order TIME NOT NULL,
	ID_Customer INT NOT NULL,
	FOREIGN KEY (ID_Customer) REFERENCES Customer(ID_Customer)
);

CREATE TABLE Bill_Line(
	ID_Bill_Line SERIAL PRIMARY KEY,
	ID_Bill INT NOT NULL,
	ID_Food INT NOT NULL,
	Quantity INT NOT NULL, 
	FOREIGN KEY (ID_Bill) REFERENCES Bill(ID_Bill),
	FOREIGN KEY (ID_Food) REFERENCES Food(ID_Food)
);

CREATE TABLE Table_Order(
	ID_Table SERIAL PRIMARY KEY,
	status BOOLEAN DEFAULT FALSE,
	ID_Bill INT,
	FOREIGN KEY (ID_Bill) REFERENCES Bill(ID_Bill)
);

CREATE TABLE Account(
	Name_Account VARCHAR(100) NOT NULL,
	Phone VARCHAR(16) NOT NULL,
	Score INT DEFAULT 0,
	PRIMARY KEY(Phone,Name_Account),
	FOREIGN KEY (Phone) REFERENCES Customer(Phone)
);

CREATE TABLE Employee(
	ID_Employee SERIAL PRIMARY KEY, 
	Name_Employee VARCHAR(50) NOT NULL,
	Phone VARCHAR(16) NOT NULL,
	Email VARCHAR(50) NOT NULL,
	CCCD VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Shift(
	ID_Shift SERIAL PRIMARY KEY,
	Date_Shift DATE NOT NULL,
	Time_Shift TIME NOT NULL
);

CREATE TABLE Schedule(
	ID_Shift INT NOT NULL,
	ID_Employee INT NOT NULL,
	FOREIGN KEY (ID_Shift) REFERENCES Shift(ID_Shift),
	FOREIGN KEY (ID_Employee) REFERENCES Employee(ID_Employee),
	PRIMARY KEY(ID_Shift, ID_Employee)
);


