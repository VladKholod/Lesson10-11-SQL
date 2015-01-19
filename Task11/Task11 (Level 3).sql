--6.������� ���������, ������� ���������� ������� �������� SalesOrderID,
--	� ������� ������� �� ������� Sales.SalesOrderDetail ��� ������, ������������� ������� ������.

create procedure DeleteSalesOrderDetailsBySalesOrderID @SalesOrderID int
with execute as owner as
begin
	delete from Sales.SalesOrderDetail
	where SalesOrderDetailID in 
		(select sod.SalesOrderDetailID
		from Sales.SalesOrderDetail as sod
		where sod.SalesOrderID = @SalesOrderID)
end;
go
--7.�������� ���������, ������� ������� ������, � ������� ���� ������� ������ 6 �������.

create procedure DeleteSalesOrderDetailsWhereOrderQtyMoreThanSix
with execute as owner as
begin
	delete from Sales.SalesOrderDetail
	where OrderQty > 6
end;
go

create procedure DeleteSalesOrderDetailsWhereProductMoreThanSix
with execute as owner as
begin
	delete from Sales.SalesOrderDetail
	where SalesOrderID in
		(select sod.SalesOrderID
		from Sales.SalesOrderDetail as sod
		group by sod.SalesOrderID
		having count(sod.ProductID) > 6)
end;
go

--8.�������� ���������, ������� ���������� ���������� ����� � �������, ��� ������� �� �������� ��� ������� ��������.

create type LocalTableType as table
(LocationName varchar(50)
, CostRate int );
go

create procedure AmountOfRows 
	@TableName LocalTableType readonly,
	@AmountRow int output
	as
		select @AmountRow = count(*)
		from @TableName;
go

--9.�������� �������, ������� �������� ��� ������� ������� Sales.SalesOrderDetail. 
--� ��� ������� ������ �������������� ���� SalesOrderId � ���� �������.

create trigger UpdateLog
	on Sales.SalesOrderDetail
	after update
as
begin
	insert into dbo.SalesOrderLog(SalesOrderId,UpdateDate)
	select d.SalesOrderID, GETDATE()
	from deleted d
end;
go

use AdventureWorks2012;



--1.��� ������, � ������� ������� ����� ����� ������ � ����� �������� ������ 10 ����, ��������� ���� ������ �� 25% 

update Sales.SalesOrderHeader
set SubTotal = SubTotal - (SubTotal/4 + TaxAmt/4 + Freight/4)
where SalesOrderID in 
	(select soh.SalesOrderID
	from Sales.SalesOrderHeader as soh
	where DATEDIFF(day, soh.OrderDate, soh.ShipDate) > 7);

--2.�������� ����� ����� ���������� � ���� �S� ��� ���� �����������,
--	� ������� � ���������������� ���������� ����� 10 �������.

update HumanResources.Employee
set LoginID = LoginID + 'S'
where BusinessEntityID in 
	(select e1.BusinessEntityID
	from HumanResources.Employee as e1
	join HumanResources.Employee as e2
		on e1.OrganizationNode = e2.OrganizationNode.GetAncestor(1)
	group by e1.BusinessEntityID
	having count(e2.BusinessEntityID) > 10);

--3.������� ������, ������� �� ���� �������, ������� ������ �������� ������� (����� � ���).

--delete from Production.Product
--where ProductID in(
select p.ProductID, p.Name
from Production.Product as p
where p.ProductID not in 
	(select distinct sod.ProductID
	from Sales.SalesOrderDetail as sod)
order by p.ProductID
--)
;

--4.�������� ������� 'Milk� � ������� ���������, ����� �������,
--	����� ��������� �������� ����� ��������, ����� �����, ��������� � ��������� ProductID=4.

insert into Production.Product (Name,Class,Color,DaysToManufacture,DiscontinuedDate,
		FinishedGoodsFlag,ListPrice,MakeFlag,ModifiedDate,ProductLine,
		ProductModelID,ProductNumber,ProductSubcategoryID,ReorderPoint,
		SafetyStockLevel,SellEndDate,SellStartDate,Size,SizeUnitMeasureCode,
		StandardCost,Style,Weight,WeightUnitMeasureCode) 
select 'Milk',p.Class,p.Color, p.DaysToManufacture,
	 p.DiscontinuedDate,p.FinishedGoodsFlag,
	 p.ListPrice,p.MakeFlag,p.ModifiedDate,
	 p.ProductLine,p.ProductModelID,
	 'XQ-9990',p.ProductSubcategoryID,
	 p.ReorderPoint,
	 p.SafetyStockLevel,p.SellEndDate,
	 p.SellStartDate,p.Size,p.SizeUnitMeasureCode,
	 p.StandardCost,p.Style,p.Weight,p.WeightUnitMeasureCode
	  from Production.Product p where ProductID = 4;

--5.�����������, ��� � ������� � ���������� ���������� �������� � ����������� �������. 
--	��� ���������� �������� ������� � ���������� ����������,��������� �������. 

delete from Production.Product
where ProductID in 
(
select p1.ProductID
from Production.Product as p1
join Production.Product as p2
	on p1.Name = p2.Name and 
	p1.ProductID <> p2.ProductID and p1.ProductID < p2.ProductID);

delete from Production.Product
where ProductID in 
(
select p2.ProductID
from Production.Product as p1
join Production.Product as p2
	on p1.Name = p2.Name and 
	p1.ProductID <> p2.ProductID and p1.ProductID > p2.ProductID);

