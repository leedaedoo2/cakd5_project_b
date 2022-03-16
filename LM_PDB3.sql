alter table purcust add 분기 number(2);

update purprod set 분기 = 1 where year = 2014 and month in (1,2,3);
update purprod set 분기 = 2 where year = 2014 and month in (4,5,6);
update purprod set 분기 = 3 where year = 2014 and month in (7,8,9);
update purprod set 분기 = 4 where year = 2014 and month in (10,11,12);

update purprod set 분기 = 5 where year = 2015 and month in (1,2,3);
update purprod set 분기 = 6 where year = 2015 and month in (4,5,6);
update purprod set 분기 = 7 where year = 2015 and month in (7,8,9);
update purprod set 분기 = 8 where year = 2015 and month in (10,11,12);

create table purcust2 as
select 고객번호, 제휴사, 대분류코드, 중분류코드, 소분류코드, 구매금액, 분기
from purprod;

update purcust2 set 구매금액 = 구매금액/0.92 where "분기" = 1;
update purcust2 set 구매금액 = 구매금액/0.952 where "분기" = 2;
update purcust2 set 구매금액 = 구매금액/0.888 where "분기" = 3;
update purcust2 set 구매금액 = 구매금액/1.136 where "분기" = 4;
update purcust2 set 구매금액 = 구매금액/0.936 where "분기" = 7;
update purcust2 set 구매금액 = 구매금액/1.168 where "분기" = 8;

select 분기, sum(구매금액) from purcust2 group by 분기 order by 분기;
commit;

update purcust2 set 분기 = 1 where 분기 = 2;
update purcust2 set 분기 = 2 where 분기 = 3 or 분기 = 4;
update purcust2 set 분기 = 3 where 분기 = 5 or 분기 = 6;
update purcust2 set 분기 = 4 where 분기 = 7 or 분기 = 8;
commit;

create table purcust3 as
select p1.고객번호, p1.제휴사, p1.성별, p1.연령대, p1.구매금액, p1.거주지역, p1.분기, p2.공통분류 from purcust2 p1, prodcl p2 where p1.제휴사 = p2.제휴사 and p1.대분류코드 = p2.대분류코드 and p1.중분류코드 = p2.중분류코드 and p1.소분류코드 = p2.소분류코드;

select 공통분류, sum(구매금액) from purcust3 group by 공통분류;

select 분기, 공통분류, sum(구매금액) from purcust3 group by 분기, 공통분류 order by 공통분류, 분기;

select 공통분류, round(count(*) * 100.0 / sum(count(*)) over (),2) as ratio from purcust3 group by 공통분류 order by ratio;

create table purcust4 as
select a.고객번호, a.성별, a.연령대, a.거주지역, a."14년도_상반기",a."14년도_하반기",a."15년도_상반기",a."15년도_하반기",  b."14년 상반기 구매총액",b."14년 하반기 구매총액", b."15년 상반기 구매총액", b."15년 하반기 구매총액"  from custdemo a, pur_area31 b where a.고객번호 = b.고객번호;

CREATE TABLE PUR_AREA31 AS SELECT custdemo.고객번호,
COUNT(CASE WHEN 분기 = 1 THEN custdemo.고객번호 END) "14년 상반기 구매건수", 
COUNT(CASE WHEN 분기 = 2 THEN custdemo.고객번호 END) "14년 하반기 구매건수", 
COUNT(CASE WHEN 분기 = 3 THEN custdemo.고객번호 END) "15년 상반기 구매건수", 
COUNT(CASE WHEN 분기 = 4 THEN custdemo.고객번호 END) "15년 하반기 구매건수", 
SUM(CASE WHEN 분기 = 1 THEN 구매금액 END) "14년 상반기 구매총액",
SUM(CASE WHEN 분기 = 2 THEN 구매금액 END) "14년 하반기 구매총액",
SUM(CASE WHEN 분기 = 3 THEN 구매금액 END) "15년 상반기 구매총액",
SUM(CASE WHEN 분기 = 4 THEN 구매금액 END) "15년 하반기 구매총액" FROM PURCUST3
LEFT OUTER JOIN custdemo ON PURCUST3.고객번호 = custdemo.고객번호
GROUP BY custdemo.고객번호;

update pur_area31 set "14년 상반기 구매건수" = 1 where "14년 상반기 구매건수" > 0;
update pur_area31 set "14년 하반기 구매건수" = 1 where "14년 하반기 구매건수" > 0;
update pur_area31 set "15년 상반기 구매건수" = 1 where "15년 상반기 구매건수" > 0;
update pur_area31 set "15년 하반기 구매건수" = 1 where "15년 하반기 구매건수" > 0;

create table 기존고객 as
select * from pur_area31 where "14년 상반기 구매건수"=1 and "14년 하반기 구매건수"=1 and "15년 상반기 구매건수"=1 and "15년 하반기 구매건수"=1;

alter table pur_area31 add 고객분류코드 number(10);

update pur_area31 set "고객분류코드" = "14년 상반기 구매건수"*1000 + "14년 하반기 구매건수"*100 + "15년 상반기 구매건수"*10 + "15년 하반기 구매건수";

create table 신규고객 as
select * from pur_area31 where "고객분류코드" = 10 or "고객분류코드" = 1 or "고객분류코드"= 11;

create table 이탈고객 as
select * from pur_area31 where "고객분류코드" = 1000 or "고객분류코드" = 1100 or "고객분류코드" = 1110 or "고객분류코드" = 1010 or "고객분류코드"=100 or "고객분류코드" = 110;

select count(*) from 기존고객;

select count(*) from 신규고객;

select count(*) from 이탈고객;

select "고객분류코드", count(*) from pur_area31 group by "고객분류코드";

--  기존고객 데이터 탐색
create table 기존고객구매정보 as
select 고객번호, 제휴사, 성별, 연령대, 구매금액, 거주지역, 공통분류, 분기 from purcust3 where "고객번호" in (select 고객번호 from 기존고객);

select 분기, sum(구매금액) from 기존고객구매정보 group by 분기 order by 분기;

select 공통분류, sum(구매금액) 총구매액 from 기존고객구매정보 group by 공통분류 order by 총구매액 desc;

select 분기,공통분류, sum(구매금액), count(*) from 기존고객구매정보 group by 분기, 공통분류 order by 공통분류,  분기;
commit;

create table 신규고객구매정보 as
select 고객번호, 제휴사, 성별, 연령대, 구매금액, 거주지역, 공통분류, 분기 from purcust3 where "고객번호" in (select 고객번호 from 신규고객);

select 분기, sum(구매금액),count(*) from 신규고객구매정보 group by 분기 order by 분기;
commit;

create table 이탈고객구매정보 as
select 고객번호, 제휴사, 성별, 연령대, 구매금액, 거주지역, 공통분류, 분기 from purcust3 where "고객번호" in (select 고객번호 from 이탈고객);

select 분기, sum(구매금액),count(*) from 이탈고객구매정보 group by 분기 order by 분기;
commit;