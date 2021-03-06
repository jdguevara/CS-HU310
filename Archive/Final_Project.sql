create database cs310project;

use cs310project;

-- 1. Create a table for Concession Items
create table Item (
ID int auto_increment,
ItemCode varchar(5) unique,
ItemDescription varchar(50) not null,
Price decimal(4,2) default 0,
primary key (ID));
-- couldn't create the table without defining the auto_increment as a key (according to MySQL)

-- Tests for Item table --
Insert into Item (ItemCode,ItemDescription, Price) Values ('A','aa',5),('A','aaaa',4); -- worked error was due to duplication (i.e. uniqueness was checked)
Insert into Item (ItemCode,ItemDescription, Price) Values ('B','aa',5),('B','aaaa',4); -- checking to make sure previous wasn't due to just being 'A'

Insert into Item (ItemCode, Price) Values ('B',5); -- ItemDescription checked for value, no default given not null constraint
Insert into Item (ItemCode, Price) Values ('J',5); -- same test as above, to make sure it wasn't the first value
Insert into Item (ItemCode, Price) Values ('J',6); -- this one makes sure it wasn't because of the second value

-- Insert into Item(ItemCode, ItemDescription, Price) Values ('Drink','Large Soda') ; -- This is not flying with MySQL as there's no Price value being given
Insert into Item(ItemCode, ItemDescription) Values ('Drink','Large Soda') ; -- This one should allow for us to insert the values and have Price use its default
Select Id, Price from Item Where ItemCode = 'Drink';

Update Item Set Price =4.50 Where ItemCode='Drink'; -- updates the price of our "Drink" to 4.50

-- 2. Storage for purchases
drop table Purchase;
create table Purchase (
ID int auto_increment
, ItemID int
, Quantity int not null
, PurchaseDate datetime not null
, primary key (ID)
, foreign key (ItemID) references Item(ID));

-- Tests for Purchase table --
Insert into Purchase (ItemID,Quantity, PurchaseDate) Values (-8, 1, Now()); -- tests the foreign key constraint of ItemID
Insert into Purchase (ItemID,Quantity, PurchaseDate) Values (2, 1, Now()); -- testing to make sure it's not because the value was negative

Insert into Purchase (ItemID, PurchaseDate) Values (1,  Now()); -- Makes sure that Quantity picked up on the fact it had nothing (i.e. null)

Insert into Purchase (ItemID,Quantity) Values (1, 1); -- Makes sure that it's receiving a PurchaseDate value

-- adding two values into Purchase and checking for them
Insert into Purchase (ItemID,Quantity, PurchaseDate) Values (1, 1, Now());
Insert into Purchase (ItemID,Quantity, PurchaseDate) Values (1, 1, Now());
Select * from Purchase ;

-- 3. Storage for Shipments
create table Shipment (
ID int auto_increment
, ShipmentDate datetime not null
, ItemID int 
, Quantity int not null
, primary key (ID)
, foreign key (ItemID) references Item(ID));

-- Tests for Shipments table --
Insert into Shipment(ShipmentDate,ItemID,Quantity) Values (Now(), -9, 3); -- tests the ItemID constraint
Insert into Shipment(ShipmentDate,ItemID,Quantity) Values (Now(), 9, 3); -- makes sure the ItemID constraint works with positive values as well

Insert into Shipment(ItemID,Quantity) Values (1, 3); -- tests that ShipmentDate isn't empty

Insert into Shipment(ShipmentDate,ItemID) Values (Now(), 1); -- tests to make sure Quantity isn't empty

-- tests insertion into Shipment -- 
Insert into Shipment(ShipmentDate,ItemID,Quantity) Values (Now(),1, 1);
Insert into Shipment(ShipmentDate,ItemID,Quantity) Values (Now(),1,1);
Select * from Shipment;
