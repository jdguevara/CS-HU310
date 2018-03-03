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

-- 4. Procedure for creating an item --
delimiter //

create procedure CreateItem (paramCode varchar(5), paramDescription varchar(50), paramPrice decimal(4,2))
begin
	insert into Item(ItemCode, ItemDescription, Price)
    values (paramCode, paramDescription, paramPrice);
end //

delimiter ;

-- Procedure for creating a shipment --
delimiter //

create procedure CreateShipment (paramShipDate datetime, paramCode varchar(5), paramQuantity int)
begin    
	set @itemID := (select ID from Item where ItemCode = paramCode);
	insert into Shipment(ShipmentDate, ItemID, Quantity)
	values (paramShipDate, @itemID, paramQuantity);
end //

delimiter ;

-- Procedure for creating a purchase --
delimiter //

create procedure CreatePurchase (paramCode varchar(5), paramQuantity int, paramPurchaseDate datetime)
begin
	insert into Purchase (ItemID, Quantity, PurchaseDate)
    values ((select ID from Item where ItemCode = paramCode), paramQuantity, paramPurchaseDate);
end //

delimiter ;

-- Tests for procedure success --
Call CreateItem ('Candy','All Candy Same Price', 4.50);
Call CreateShipment(Now(),'Candy',5);
Call CreatePurchase('Candy', 1,Now());

-- 5. Procedure for getting an item based on code --
delimiter //

create procedure GetItems (paramCode varchar(5))
begin
	select * from Item where ItemCode like paramCode;
end //

delimiter ;

-- Procedure for getting shipment records based on date made--
delimiter //

create procedure GetShipments (thisDate date)
begin
	select * from Shipment where cast(ShipmentDate as date) = thisDate;
end //

delimiter ;

-- Procedure for getting purchase records based on date made --
delimiter //

create procedure GetPurchases (thisDate date)
begin
	select * from Purchase where cast(PurchaseDate as date) = thisDate;
end //

delimiter ;

-- Tests for reading procedure success --
Call GetItems ('%');     -- returns all Items
Call GetItems ('d');     -- returns no Items
Call GetItems ('Drink'); -- returns 1 Item
Call GetItems ('Candy'); -- extra test --
Call GetShipments("2018-02-19");
Call GetPurchases("2018-02-19");
Call GetShipments("2018-02-11"); -- extra test based on my db data --
Call GetPurchases("2018-02-11"); -- extra test based on my db data --

-- 6. Procedure for reporting available quantities for a given item --
delimiter //

create procedure ItemsAvailable (pCode varchar(5)) 
begin
	select ItemCode as 'Code', ItemDescription as 'Description', ifnull(sum(Shipment.Quantity)-sum(Purchase.Quantity), 0) as 'Available Quantity'
    from Item
    inner join Shipment
		on Shipment.ItemID = Item.ID
	inner join Purchase
		on Purchase.ItemID = Item.ID
    where ItemCode like pCode
    group by ItemCode, ItemDescription;
end //

delimiter ;

-- Test for reporting procedure --
Call ItemsAvailable('Drink');  -- returns one record , no duplicates exist
call ItemsAvailable('%'); -- returns all quantity records for the available items
call ItemsAvailable('Candy'); -- Extra test
call ItemsAvailable('Ice'); -- Test for items that doesn't exist should not return anything

-- New Test for an item with no shipment/purchase --
insert into Item(ItemCode, ItemDescription, Price) values ('Chips', 'All the Chips', 5.00); 
insert into Shipment(ShipmentDate, ItemID, Quantity) values (now(), 3, 0);
Insert into Purchase (ItemID,Quantity, PurchaseDate) Values (3, 0, Now());
call ItemsAvailable('Chips');

-- 7. Update Procedures --

-- Update Shipments --
delimiter //

create procedure UpdateShipment (pShipmentDate date, pItemCode varchar(5), pQuantity int)
begin
	update Shipment
    set Quantity = pQuantity
    where Shipment.ItemID = (select ID from Item where ItemCode = pItemCode) and cast(Shipment.ShipmentDate as date) = pShipmentDate;
end //

delimiter ;

-- Tests for UpdateShipment -- 
call UpdateShipment ("2018-02-11", 'Drink', 5); -- These first two will change up the values currently existing
call UpdateShipment ("2018-02-19", 'Candy', 1);
call UpdateShipment ("2018-02-11", 'Drink', 1); -- These last two should update them to their original quantities
call UpdateShipment ("2018-02-19", 'Candy', 5);
call UpdateShipment ('Candy', 5); -- Test for the correct number of parameters

-- Update Items --
delimiter //

create procedure UpdateItem (pItemCode varchar(5), pDescription varchar(50), pPrice decimal(4,2))
begin
	update Item
    set ItemDescription = pDescription, Price = pPrice
    where ItemCode = pItemCode;
end //

delimiter ;

-- Tests for UpdateItem -- 
call UpdateItem('Candy', 'New candy', 5.50);
call UpdateItem('Candy', 'All candy same price', 4.50);

-- Update Purchases --
delimiter //

create procedure UpdatePurchase (pItemCode varchar(5), pQuantity int, pPurchaseDate date)
begin
	update Purchase
    set Quantity = pQuantity
    where Purchase.ItemID = (select ID from Item where ItemCode = pItemCode) and cast(Purchase.PurchaseDate as date) = pPurchaseDate;
end //

delimiter ;

-- Tests for UpdatePurchase -- 
call UpdatePurchase ('Drink', 5, "2018-02-11"); -- These first two will change up the values currently existing
call UpdatePurchase ('Candy', 5, "2018-02-19");
call UpdatePurchase ('Drink', 1, "2018-02-11"); -- These last two should update them to their original quantities
call UpdatePurchase ('Candy', 1, "2018-02-19");
call UpdatePurchase ('Candy', 5); -- Test for the correct number of parameters

-- 8. Delete Procedures --

-- Deleting a Shipment --
delimiter //

create procedure DeleteShipment (pShipmentDate date, pCode varchar(5))
begin
	delete from Shipment
    where cast(ShipmentDate as date) = pShipmentDate and ItemID = (select ID from Item where ItemCode = pCode);
end //

delimiter ;

-- Test DeleteShipment -- 
call DeleteShipment(cast(now() as date), 'Chips');
insert into Shipment(ShipmentDate, ItemID, Quantity) values (now(), 3, 0);
call DeleteShipment(cast(now() as date), 'Chips');

-- Deleting an Item -- 
delimiter //

create procedure DeleteItem (pCode varchar(5))
begin
	delete from Item
    where ItemCode = pCode;
end //

delimiter ;

-- Tests for DeleteItem --
call DeleteItem('Chips'); -- Won't be able to do this at the moment as it is tied to Shipment and Purchase through their FKs

-- Deleting a Purchase --
delimiter //

create procedure DeletePurchase (pPurchaseDate date, pCode varchar(5))
begin
	delete from Purchase
    where cast(PurchaseDate as date) = pPurchaseDate and ItemID = (select ID from Item where ItemCode = pCode);
end //

delimiter ;

-- Test DeletePurchase -- 
call DeletePurchase(cast(now() as date), 'Chips');
Insert into Purchase (ItemID,Quantity, PurchaseDate) Values (3, 0, Now());
call DeletePurchase(cast(now() as date), 'Chips');

-- Try the previous DeleteItem test again --
call DeleteItem('Chips'); -- Should now work that both the Shipment and Purchase tied to it have been deleted, freing it up from their FKs
