#Datenbankerstellen
Create database if not exists restaurant_db;
Use restaurant_db;

#CSV Reinladen
CREATE TABLE Customers (
    Customer_ID VARCHAR(10) PRIMARY KEY,
    Last_name VARCHAR(100),
    Email VARCHAR(255),
    Phone_number VARCHAR(20)
);

drop table if exists reservations
;
CREATE TABLE reservations (
    Reservation_ID int(10) PRIMARY KEY,
    day_date date,
    time_reservation time, 
    is_online boolean,
    customer_id varchar(100),
    no_show boolean,
    count_persons int(10)
);

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Date_da DATE NOT NULL,
    Time_order TIME NOT NULL,
    Time_checkout TIME NOT NULL,
    Amount_price DECIMAL(10,2) NOT NULL,
    Reservation_ID INT NULL,
    Customer_ID VARCHAR(10) NULL,
    Table_ID VARCHAR(10) NOT NULL
);
select * from customers