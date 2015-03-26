//生日问题
select name ,birthday ,
	if(cur > today , cur,next) as birth_day
from (
	select name ,birthday,today,
		DATE_ADD(cur , interval if(day(birthday)=29&&day(cur) =28,1,0) day) as cur,
		DATE_ADD(next, interval if(day(birthday)=29&&day(next)=28,1,0) day) as next 
	from(
	    select name ,birthday,today,
	    	   date_add(birthday,interval diff year) as cur,
	              date_add(birthday,interval diff+1 year) as next 
	    from(
	    	select concat(last_name, ' ' ,first_name) as name,birth_date as Birthday,(year(now())-year(birth_date)) as diff,now() as today 
	    	from employees
	    	) as a
	    ) as b
) as c;


//重叠问题
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app` varchar(10) NOT NULL,
  `usr` varchar(10) NOT NULL,
  `starttime` time NOT NULL,
  `endtime` time NOT NULL,
  PRIMARY KEY (`id`)
);
insert into sessions (app,usr,starttime,endtime)values('app1','user1','08:30','10:30');
insert into sessions (app,usr,starttime,endtime)values('app1','user2', '08:30','08:45');	
insert into sessions (app,usr,starttime,endtime)values('app1','user1','09:00','09:30');
insert into sessions (app,usr,starttime,endtime)values('app1','user2','09:15','10:30');
insert into sessions (app,usr,starttime,endtime)values('app1','user1','09:15','09:30');
insert into sessions (app,usr,starttime,endtime)values('app1','user2','10:30','14:30');
insert into sessions (app,usr,starttime,endtime)values('app1','user1','10:45','11:30');
insert into sessions (app,usr,starttime,endtime)values('app1','user2','11:00','12:30');
insert into sessions (app,usr,starttime,endtime)values('app2','user1','08:30','08:45');
insert into sessions (app,usr,starttime,endtime)values('app2','user2','09:00','09:30');
insert into sessions (app,usr,starttime,endtime)values('app2','user1','11:45','12:00');
insert into sessions (app,usr,starttime,endtime)values('app2','user2','12:30','14:30');
insert into sessions (app,usr,starttime,endtime)values('app2','user1','12:45','13:30');
insert into sessions (app,usr,starttime,endtime)values('app2','user2','13:00','14:00');
insert into sessions (app,usr,starttime,endtime)values('app2','user1','14:00','16:30');
insert into sessions (app,usr,starttime,endtime)values('app2','user2','15:30','17:00');
//创建索引
create unique index idx_app_user_s_e_key on sessions(app,usr,starttime,endtime,id);
create index idx_app_user_s_e on sessions(app,starttime,endtime);

(1)标尺重叠
select a.app , a.usr,a.starttime,a.endtime,b.starttime,b.endtime 
from sessions as a, sessions as b where a.app=b.app and a.usr=b.usr and (b.starttime <= a.endtime and b.endtime >= a.starttime)

(2)分组重叠

select distinct app,id,usr,starttime as s 
from sessions as a 
where not exists (
	select * from sessions b where 
		a.app=b.app 
		and a.usr=b.usr 
		and a.starttime >b.starttime 
		and a.starttime <=b.endtime
)
select distinct app,id,usr,endtime as e 
from sessions as a 
where not exists (
	select * from sessions b where 
		a.app=b.app 
		and a.usr=b.usr 
		and a.endtime >=b.starttime 
		and a.endtime <b.endtime
)

select DISTINCT s.app ,s.usr,s.s,
(
	select MIN(e)
	FROM( 
		select distinct app,id,usr,endtime as e 
		from sessions as a 
		where not exists (
			select * 
			from 
			sessions b 
			where 
			a.app=b.app 
			and a.usr=b.usr 
			and a.endtime >=b.starttime 
			and a.endtime <b.endtime
		)
	) AS s2
	where s2.e > s.s and s.app = s2.app and s.usr=s2.usr
) as e
FROM
(
	select distinct app,id,usr,starttime as s 
	from sessions as a 
		where not exists (
			select * 
			from 
			sessions b where 
			a.app=b.app 
			and a.usr=b.usr 
			and a.starttime >b.starttime 
			and a.starttime <=b.endtime
		)

) AS s,
(
	select distinct app,id,usr,endtime as e 
	from sessions as a 
	where not exists (
		select * 
		from sessions b 
		where 
		a.app=b.app 
		and a.usr=b.usr 
		and a.endtime >=b.starttime 
		and a.endtime <b.endtime
	)

)
as e
where s.app =e.app and s.usr =e.usr;	

(3)最大重叠会话数

select app,MAX(count) as max 
FROM(
	select app, s,
	(
		select count(1) 
		from 
		sessions as b 
		where 
		s>=starttime 
		and s<endtime
	)as count
	FROM (
			select 
			DISTINCT app,starttime as s 
			FROM 
			sessions 
		) as a

)AS bc
group by app;

//星期几问题
1）计算日期是星期几
set @a='2011-01-01';
select WEEKDAY(@a),DAYOFWEEK(@a),DAYNAME(@a);
set lc_time_names='zh_CN';//控制 DAYNAME显示中文星期


/************************************************************************************
*************************************************************************************/


查询处理

练习sql

create table customers
(
    customer_id varchar(10) not null,
    city varchar(10) not null,
    primary key(customer_id)
 )engine=INNODB;
insert into customers values ('163','HangZhou'),('9you','ShangHai'),('TX','HangZhou'),('baidu','HangZhou');

create table orders
(
	order_id int not null AUTO_INCREMENT,
	customer_id varchar(10),
	primary key(order_id)
)	engine=INNODB;
insert into orders (customer_id)values ('163'),('163'),('9you'),('9you'),('9you'),('TX'),(null);

select c.customer_id,count(o.order_id) as num  
from  customers as c
left join orders as o
on c.customer_id =o.customer_id
where c.city = 'HangZhou'
group by c.customer_id
having count(o.order_id) <2
order by num desc


/************************************************************************************************************/
//子查询可以解决的经典问题

1.行号
准备数据

create table sales (
	empid varchar(10) not null,
	mgrid  varchar(10) not null,
	qty int not null,
	primary key (empid)
);
insert into sales values ('A','Z',300);
insert into sales values ('B','X',100);
insert into sales values ('C','X',200);
insert into sales values ('D','Y',200);
insert into sales values ('E','Z',250);
insert into sales values ('F','Z',300);
insert into sales values ('G','X',100);
insert into sales values ('H','Y',150);
insert into sales values ('I','X',250);
insert into sales values ('J','Z',100);
insert into sales values ('K','Y',200);

select empid ,( select count(*) from sales as t2 where t2.empid <= t1.empid ) as rownum from sales as t1;

2分区

select dept_no,emp_no ,
(
	select count(*) 
	from dept_manager as s2 
	where s1.dept_no = s2.dept_no
	and s2.emp_no <= s1.emp_no
) as rownum 
from dept_manager as s1 order by dept_no , emp_no;	



3缺失范围

select a+1 as start_range , (select min(a)-1 from t as C where C.a>g.a) as end_range from t as g where not exists (select * from t as B  where g.a+1=B.a) and a < (select max(a) from t)




//联接查询


滑动订单问题

create table monthlyorders(
	ordermonth DATE,
	ordernum int unsigned,
	PRIMARY key (ordermonth)
);
insert into monthlyorders values ('2010-02-01',23);
insert into monthlyorders values ('2010-03-01',26);
insert into monthlyorders values ('2010-04-01',24);
insert into monthlyorders values ('2010-05-01',27);
insert into monthlyorders values ('2010-06-01',26);
insert into monthlyorders values ('2010-07-01',32);
insert into monthlyorders values ('2010-08-01',34);
insert into monthlyorders values ('2010-09-01',30);
insert into monthlyorders values ('2010-10-01',31);
insert into monthlyorders values ('2010-11-01',32);
insert into monthlyorders values ('2010-12-01',33);
insert into monthlyorders values ('2011-01-01',31);
insert into monthlyorders values ('2011-02-01',34);
insert into monthlyorders values ('2011-03-01',34);
insert into monthlyorders values ('2011-04-01',38);
insert into monthlyorders values ('2011-05-01',39);
insert into monthlyorders values ('2011-06-01',35);
insert into monthlyorders values ('2011-07-01',49);
insert into monthlyorders values ('2011-08-01',56);
insert into monthlyorders values ('2011-09-01',55);
insert into monthlyorders values ('2011-10-01',74);
insert into monthlyorders values ('2011-11-01',75);
insert into monthlyorders values ('2011-12-01',14);	