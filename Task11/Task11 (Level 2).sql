use AdventureWorks2012;

--1.���������� ���������� ����� ���������� �� ������� ������� �� ������ 2001-2004�� � ������������ �� ����� � �� �����������

select top 10 soh.SalesPersonID as [By Sales Person], SUM(soh.TotalDue) as [Total Due Sum], null as [By Year]
from Sales.SalesOrderHeader as soh 
where year(soh.OrderDate) between 2005 and 2008  group by soh.SalesPersonID
union
select null, sum(soh.TotalDue), year(soh.OrderDate) as [By Year]
from Sales.SalesOrderHeader as soh
group by year(soh.OrderDate) order by [By Year];

--2.�� �� �����, �� ��������� � ���� ������� �� ���������: ���������, 2001, 2002, 2003, 2004

select soh1.SalesPersonID,
	(select sum(soh2.TotalDue)
	from Sales.SalesOrderHeader as soh2
	where soh1.SalesPersonID = soh2.SalesPersonID and
	year(soh2.OrderDate) = 2005) as [2005],

	(select sum(soh2.TotalDue)
	from Sales.SalesOrderHeader as soh2
	where soh1.SalesPersonID = soh2.SalesPersonID and
	year(soh2.OrderDate) = 2006) as [2006],
	
	(select sum(soh2.TotalDue)
	from Sales.SalesOrderHeader as soh2
	where soh1.SalesPersonID = soh2.SalesPersonID and
	year(soh2.OrderDate) = 2007) as [2007],
	
	(select sum(soh2.TotalDue)
	from Sales.SalesOrderHeader as soh2
	where soh1.SalesPersonID = soh2.SalesPersonID and
	year(soh2.OrderDate) = 2008) as [2008]
from Sales.SalesOrderHeader as soh1
where SalesPersonID is not null
group by soh1.SalesPersonID;

--3.������������� ���� ����������� �������� �� ���� �������� � ������� � 10-��� �� 20-���

select p.BusinessEntityID, p.LastName, p.FirstName, e.BirthDate
from HumanResources.Employee as e, Person.Person as p
where e.BusinessEntityID = p.BusinessEntityID
order by e.BirthDate
offset 9 rows fetch next 11 rows only;

--4.������� �����������, � ������� � 2003 ���� ���� �������, ����������� �� ����� ������������ ������� 2002 ����

select poh1.VendorID, poh1.TotalDue, poh1.OrderDate
from Purchasing.PurchaseOrderHeader as poh1
where year(poh1.OrderDate) = 2006 and poh1.TotalDue >
	(select max(poh2.TotalDue) 
	from Purchasing.PurchaseOrderHeader as poh2
	where poh2.VendorID = poh1.VendorID and year(poh2.OrderDate) = 2005);

--5.����� ���� �����������, ������� �� ������� ������� ������� � 1 �������� 2003�.

select soh1.CustomerID
from Sales.SalesOrderHeader as soh1
where soh1.CustomerID not in 
	(select soh2.CustomerID
	from Sales.SalesOrderHeader as soh2
	where soh2.OrderDate between '2008-01-01' and '2008-03-31');

--6.������� �����������, ������ ������� �� ���� ������� � ������ � 2003

select distinct poh1.VendorID
from Purchasing.PurchaseOrderHeader as poh1
where poh1.VendorID not in(
	select poh.VendorID
	from Purchasing.PurchaseOrderHeader as poh
	join Purchasing.PurchaseOrderDetail as pod
		on poh.PurchaseOrderID = pod.PurchaseOrderID
	join Sales.SalesOrderDetail as sod
		on sod.ProductID = pod.ProductID
	join Sales.SalesOrderHeader as soh
		on soh.SalesOrderID = sod.SalesOrderID and year(soh.OrderDate) = 2006
	join Sales.SalesTerritory as t 
		on t.TerritoryID = soh.TerritoryID and t.[Group] = 'Europe');

--7.���������� ������� ����� ������ � ������������ �� ����������� � �����.

select poh.VendorID as [By Vendor], avg(poh.TotalDue), null as [By Year]
from Purchasing.PurchaseOrderHeader as poh
where year(poh.OrderDate) between 2005 and 2008  group by VendorID
union
select null, avg(poh.TotalDue), year(poh.OrderDate) as [By Year]
from Purchasing.PurchaseOrderHeader as poh
group by year(poh.OrderDate) order by [By Year];

--8.��� ������ ��������� ������� ���������� ����, ����� ���� ������������ ������ �������.

--category
select pc.Name, Min(p.SellStartDate) as [First sale date] 
from Production.Product as p, Production.ProductCategory as pc, Production.ProductSubcategory as psc
where p.ProductSubcategoryID = psc.ProductSubcategoryID and psc.ProductCategoryID = pc.ProductCategoryID
group by pc.Name
order by pc.Name;

--subcategory
select psc.Name, Min(p.SellStartDate) as [First sale date] 
from Production.Product as p,Production.ProductSubcategory as psc
where p.ProductSubcategoryID = psc.ProductSubcategoryID
group by psc.Name
order by psc.Name;

--9.������ ������ �� ����������� �� ������ 2003� �� ������ ���������� ������ 
--�	���������� �������
--�	����� ����� �������
--�	����� ���� ��������

select t.Name, 
	sum(sod.OrderQty) as [Amount of products],
	sum(soh.TotalDue) as [Sum of total due], 
	sum(soh.Freight) as [Sum of freight]
from Sales.SalesTerritory as t, Sales.SalesOrderHeader as soh, Sales.SalesOrderDetail as sod
where soh.TerritoryID = t.TerritoryID and soh.SalesOrderID = sod.SalesOrderID and
	soh.OrderDate between '2005-07-01' and '2005-07-31'
group by t.Name;

--10.����� 20% ����������� ������ �� ����� ������.

select top 20 percent c.CustomerID, sum(soh.TotalDue) as [Sum of total due]
from Sales.Customer as c, Sales.SalesOrderHeader as soh
where c.CustomerID = soh.CustomerID
group by c.CustomerID
order by [Sum of total due] desc;

--11.����� ��������� ���������� ���������� ����������� ���������.

select top 1 v.Name, count(p.name) as [Amount of products] 
from Purchasing.ProductVendor as pv, Purchasing.Vendor as v, Production.Product as p
where p.ProductID = pv.ProductID and pv.BusinessEntityID = v.BusinessEntityID
group by v.Name
order by [Amount of products] desc;;

--12.����� ����������, ������� �� ������ �� ������ ������

select c.CustomerID
from Sales.Customer as c
where c.CustomerID not in 
	(select soh.CustomerID 
	from Sales.SalesOrderHeader as soh);

--13.������� ������ �������, � ������� ������������ ����������� �������� � �Blade�, � �Flat Washer 1�

select sod.SalesOrderID
from Sales.SalesOrderDetail as sod, Production.Product as p
where sod.ProductID = p.ProductID and p.Name = 'Sport-100 Helmet, Red' and sod.SalesOrderID in(
	select sod.SalesOrderID
	from Sales.SalesOrderDetail as sod, Production.Product as p
	where sod.ProductID = p.ProductID and p.Name = 'LL Road Frame - Red, 60');

--14.������� ���� ���������� - �������������.

select  p.BusinessEntityID, p.LastName, p.MiddleName, p.FirstName
from HumanResources.Employee as e, Person.Person as p
where e.BusinessEntityID = p.BusinessEntityID and e.JobTitle like '%Manager%';

--15.����� ���������� ����������� � ������� ����������

select e1.BusinessEntityID, count(e2.BusinessEntityID) as [Slaves]
from HumanResources.Employee as e1
join HumanResources.Employee as e2
	on e1.OrganizationNode = e2.OrganizationNode.GetAncestor(1)
group by e1.BusinessEntityID;

--16.����� ����������, � �������� ������ ���� ��������� � ������������

select v.Name
from Purchasing.Vendor as v
where v.BusinessEntityID in 
	(select pv.BusinessEntityID
	from Purchasing.ProductVendor as pv
	group by pv.BusinessEntityID
	having count(pv.ProductID) > 3)

--17.����� �������, �� �������� ���� ����� ����������� �������

select top 1 c.CustomerID, count(soh.SalesOrderID) as [Amount of orders]
from Sales.Customer as c, Sales.SalesOrderHeader as soh
where c.CustomerID = soh.CustomerID
group by c.CustomerID
order by [Amount of orders] desc;

--18.�� ����� ���������� �������� ����� �������� ��������� �� �������� �� 2003�

select top 1 p.BusinessEntityID, t.Name as Territory
from Sales.SalesPerson as p
join Sales.SalesOrderHeader as soh
	on p.BusinessEntityID = soh.SalesPersonID and year(soh.OrderDate) = 2005
join Sales.SalesTerritory as t
	on p.TerritoryID = t.TerritoryID 
group by p.BusinessEntityID, t.Name
order by sum(soh.TotalDue) desc;