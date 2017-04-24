create table movie( movie_id smallint, movie_title string, 
genre array<string>)
row format delimited fields terminated by '#'
collection items terminated by '|' ;

load data local inpath '/home/administrator/movies.dat' into table movie;

create table movies( movie_id smallint, movie_title string, genres string);

insert into table movies
select movie_id, movie_title, genres from movie
LATERAL VIEW explode(genre) movies as genres;

create table ratings(user_id smallint, movie_id smallint, rating int, times int)
row format delimited fields terminated by '#';

load data local inpath '/home/administrator/ratings.dat' into table ratings;

create table joins(user_id smallint, movie_id int, genres string,rating int);

insert overwrite table joins
select ratings.user_id, ratings.movie_id, movies.genres, ratings.rating
from ratings
join movies
on movies.movie_id=ratings.movie_id;

create table soln( user_id smallint, genres string, ratingavg double);

insert overwrite table soln
select user_id, genres, AVG(rating)
from joins
group by user_id, genres;

insert overwrite local directory '/home/administrator/newsol' select * from soln;

insert overwrite local directory '/home/administrator/newsolution'
select user_id, genres, ratingavg from 
(select user_id, genres, ratingavg, rank() over (partition by user_id order by ratingavg desc) as rank from soln) ranked_table
where ranked_table.rank<=5;
