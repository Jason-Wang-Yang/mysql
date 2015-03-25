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
