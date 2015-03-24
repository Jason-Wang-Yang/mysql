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

insert into sessions (app,usr,starttime,endtime)values('app1','user1','10:00','10:30');



