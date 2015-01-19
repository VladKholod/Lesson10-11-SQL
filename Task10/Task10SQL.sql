use TESTERS;

--1
select * from SUBJECT;

--2
select SUBJECT.SUBJ_NAME, SUBJECT.HOUR from SUBJECT where SUBJECT.SEMESTER=4;

--3
select STUDENT.SURNAME, STUDENT.NAME, STUDENT.KURS from STUDENT where STUDENT.STIPEND > 140;

--4
select STUDENT.SURNAME, STUDENT.NAME, STUDENT.KURS from STUDENT where STUDENT.STIPEND >= 100 and STUDENT.CITY='Voroneg';

--5
select EXAM_MARKS.SUBJ_ID from EXAM_MARKS where EXAM_MARKS.EXAM_DATE between '2009-06-22 00:00:00.000' and '2010-01-23 00:00:00.000';

--6
select * from EXAM_MARKS where EXAM_MARKS.STUDENT_ID in (12,32);

--7
--Б.КУЗНЕЦОВ;местожительства-БРЯНСК;родился-8.12.81
select CONCAT
(
	SUBSTRING(STUDENT.NAME,1,1),'.',
	UPPER(STUDENT.SURNAME),'; city-', 
	UPPER(STUDENT.CITY),'; was born-', 
	CONVERT(nvarchar,STUDENT.BIRTHDAY,4)
) as [name city birthday]
from STUDENT;

--8
--б.кузнецов;место жительства-брянск;родился:8-дек-1981
select CONCAT
(
	LOWER(SUBSTRING(STUDENT.NAME,1,1)),'.',
	LOWER(STUDENT.SURNAME),'; city-', 
	LOWER(STUDENT.CITY),'; was born-', 
	DAY(STUDENT.BIRTHDAY),'-',
	LOWER(SUBSTRING(CONVERT(nvarchar,STUDENT.BIRTHDAY),1,3)),'-',
	YEAR(STUDENT.BIRTHDAY)
) as [name city birthday]
from STUDENT;

--9
--Борис Кузнецов родился в 1981 году
select CONCAT
(
	STUDENT.NAME,' ',
	STUDENT.SURNAME,' was born at', 
	YEAR(STUDENT.BIRTHDAY), ' year'
) as [name city birthday]
from STUDENT;

--10
select COUNT(EXAM_MARKS.STUDENT_ID) as [Amount of students] from EXAM_MARKS where EXAM_MARKS.SUBJ_ID=22;

--11
select COUNT(distinct(EXAM_MARKS.SUBJ_ID)) as [Amount of subjects] from EXAM_MARKS;

--12
select s1.STUDENT_ID, s1.NAME from STUDENT as s1 where s1.STIPEND  = (select max(s2.STIPEND) from STUDENT as s2 where s2.CITY=s1.CITY);

--13
select s1.STUDENT_ID, s1.NAME from STUDENT as s1 where s1.CITY not in (select distinct(UNIVERSITY.CITY) from UNIVERSITY);

--14
select s.STUDENT_ID, s.NAME from STUDENT as s, UNIVERSITY as u where s.UNIV_ID = u.UNIV_ID and s.CITY!=u.CITY;
select s.STUDENT_ID, s.NAME from STUDENT as s Full Outer Join UNIVERSITY as u on s.UNIV_ID = u.UNIV_ID where s.CITY!=u.CITY;

--15
select u1.UNIV_NAME from UNIVERSITY as u1 where u1.RATING >= (select u2.RATING from UNIVERSITY as u2 where u2.UNIV_NAME = 'VGY');

--16
select s1.STUDENT_ID, s1.NAME from STUDENT as s1 where s1.CITY <> all (select distinct(UNIVERSITY.CITY) from UNIVERSITY);

--17
select distinct(s.SUBJ_NAME) 
from EXAM_MARKS as e1, SUBJECT as s 
where e1.SUBJ_ID = s.SUBJ_ID and e1.MARK > any(select e2.MARK from EXAM_MARKS as e2 where e2.SUBJ_ID = 22);

--18
select s.SURNAME, e.SUBJ_ID 
from STUDENT as s, EXAM_MARKS as e 
where s.STUDENT_ID = e.STUDENT_ID and e.MARK is not null order by s.SURNAME;

--19
select s.SURNAME, e.SUBJ_ID 
from STUDENT as s, EXAM_MARKS as e 
where s.STUDENT_ID = e.STUDENT_ID and e.MARK is not null order by s.SURNAME;

--20
select s.SURNAME, sb.SUBJ_NAME 
from STUDENT as s, EXAM_MARKS as e, SUBJECT as sb 
where s.STUDENT_ID = e.STUDENT_ID and e.SUBJ_ID = sb.SUBJ_ID and e.MARK is not null order by s.SURNAME;

--21
select * into STUDENTI 
from STUDENT as s
where s.STUDENT_ID in
	(
		select s.STUDENT_ID 
		from EXAM_MARKS as e, STUDENT as s where s.STUDENT_ID = e.STUDENT_ID 
		group by s.STUDENT_ID 
		having COUNT(e.MARK) > 1
	)
;

select * from STUDENTI;

--22
--CREATE SUBJECTI
select * into SUBJECTI from SUBJECT;

delete from SUBJECTI where SUBJECTI.SUBJ_ID not in(select e.SUBJ_ID from EXAM_MARKS as e);

--23
update STUDENT 
set STIPEND=1.2*STIPEND 
where STUDENT_ID in
	(
		select s.STUDENT_ID from EXAM_MARKS as e, STUDENT as s where s.STUDENT_ID = e.STUDENT_ID group by s.STUDENT_ID having SUM(e.MARK) > 4
	)
;

--24
select st.SURNAME, sb.SUBJ_NAME, e.MARK 
from STUDENT as st 
inner join EXAM_MARKS as e
on st.STUDENT_ID = e.STUDENT_ID and e.MARK in(4,5)
inner join SUBJECT as sb
on sb.SUBJ_ID = e.SUBJ_ID;

--25
select s.SUBJ_NAME from SUBJECT as s where s.SUBJ_NAME like 'M%';

--26
select * from STUDENT as s where s.SURNAME like 'J%' or s.SURNAME like 'I%';

--27
select u.UNIV_NAME,u.RATING, MAX(s.STIPEND) as [Max Stipend] 
from UNIVERSITY as u, STUDENT as s 
where u.UNIV_ID = s.UNIV_ID and u.RATING > 300 group by u.UNIV_NAME, u.RATING;

--28
select s.SURNAME, u.RATING from STUDENT as s, UNIVERSITY as u where s.UNIV_ID = u.UNIV_ID
union
select s.SURNAME, null from STUDENT as s order by s.SURNAME;

--29
select s.STUDENT_ID, s.NAME 
from STUDENT as s 
where s.CITY in 
(
	select u.CITY 
	from UNIVERSITY as u 
	group by u.CITY 
	having COUNT(u.CITY) >= 2
);
		