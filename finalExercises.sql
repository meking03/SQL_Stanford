-- Movie-rating query exercises
-- 1 - Find the titles of all movies directed by Steven Spielberg.
select title
from movie
where director = 'Steven Spielberg';

-- 2 - Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
select distinct year
from movie M, rating R
where M.mID	= R.mID and stars >= 4
order by year;

-- 3 - Find the titles of all movies that have no ratings.
select title
from movie 
where mID not in (select mID from rating);

-- 4 - Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.
select name
from reviewer R1, rating R2
where R1.rID = R2.rID and ratingDate is null;

-- 5 - Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate.
-- Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.
select name, title, stars, ratingDate
from reviewer R1, rating R2, movie M
where R1.rID = R2.rID and R2.mID = M.mID
order by name, title, stars;

-- 6 - For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.
select name, title
from reviewer R1, rating R2, rating R3, movie M
where (R1.rID = R2.rID and R1.rID = R3.rID and R2.mID = R3.mID) and (R3.ratingDate > R2.ratingDate and R3.stars > R2.stars) and (R2.mID = M.mID and R3.mID = M.mID);

-- 7 - For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title.
select title, max(stars)
from movie M, rating R
where M.mID = R.mID
group by R.mID
order by title;

-- 8 - For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie.
-- Sort by rating spread from highest to lowest, then by movie title.
select title, max(stars) - min(stars) as ratingSpread
from movie M, rating R
where M.mID = R.mID
group by R.mID
order by ratingSpread desc, title;

-- 9 - Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980.
-- (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after.
-- Don't just calculate the overall average rating before and after 1980.)
select avg(R1.avgStars) - avg(R2.avgStars)
from (select avg(stars) as avgStars from rating R, movie M where R.mID = M.mID and year < 1980 group by R.mID) as R1,
(select avg(stars) as avgStars from rating R, movie M where R.mID = M.mID and year > 1980 group by R.mID) as R2;

-- Movie-rating query exercises (extras)
-- 1 - Find the names of all reviewers who rated Gone with the Wind.
select distinct name
from reviewer R1, rating R2
where R1.rID = R2.rID and mID in (select mID from movie where title = 'Gone with the Wind');

-- 2 - For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.
select name, title, stars
from reviewer R1, rating R2, movie M
where name = director and R1.rID = R2.rID and M.mID = R2.mID;

-- 3 - Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine;
-- no need for special processing on last names or removing "The".)
select C.name as finalList
from (
select name
from reviewer
union
select title
from movie) as C
order by finalList;

-- 4 - Find the titles of all movies not reviewed by Chris Jackson.
select title
from movie
where mID not in (
select distinct mID
from rating, reviewer
where rating.rID = reviewer.rID and reviewer.name = 'Chris Jackson');

-- 5 - For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers.
-- Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order.
select distinct R1.name as reviewer1, R2.name as reviewer2
from reviewer R1, reviewer R2, rating R3, rating R4
where (R3.mID = R4.mID and R3.rID <> R4.rID) and R3.rID = R1.rID and R4.rID = R2.rID and R1.name < R2.name
order by reviewer1;

-- 6 - For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.
select name, title, stars
from reviewer R1, rating R2, movie M
where R2.stars = (select min(stars) from rating) and M.mID = R2.mID and R1.rID = R2.rID;

-- 7 - List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.
select title, stars
from movie M, (select mID, avg(stars) as stars from rating group by mID) as R
where M.mID = R.mID
order by stars desc, title;

-- 8 - Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.)
select name
from reviewer R1, rating R2
where R1.rID = R2.rID
group by R2.rID
having count(R2.rID) >= 3;

-- 9 - Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name.
-- Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)
select title, director
from movie
where director in (select director from movie group by director having count(mID) > 1)
order by director, title;

-- 10 - Find the movie(s) with the highest average rating. Return the movie title(s) and average rating.
-- (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)
select title, avg(stars) as stars
from rating R1, movie M
where R1.mID = M.mID
group by R1.mID
having stars >= all (select avg(stars) from rating R2 where R1.mID <> R2.mID group by R2.mID);

-- 11 - Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating.
-- (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.)
select title, avg(stars) as stars
from rating R1, movie M
where R1.mID = M.mID
group by R1.mID
having stars <= all (select avg(stars) from rating R2 where R1.mID <> R2.mID group by R2.mID);

-- 12 - For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies,
-- and the value of that rating. Ignore movies whose director is NULL.
select director, title, max(stars)
from movie M, rating R
where M.mID = R.mID and director is not null
group by director;

-- Social-Network query exercises
-- 1 - Find the names of all students who are friends with someone named Gabriel.
select distinct H1.name
from highschooler H1, highschooler H2, friend F
where (F.id1 = H1.id and F.id2 = H2.id) and H2.name = 'Gabriel';

-- 2 - For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.
select H1.name, H1.grade, H2.name, H2.grade
from highschooler H1, highschooler H2, likes L
where (H1.id = L.id1 and H2.id = L.id2) and H1.grade - H2.grade >= 2;

-- 3 - For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.
select H1.name, H1.grade, H2.name, H2.grade
from highschooler H1, highschooler H2, likes L1, likes L2
where (H1.id = L1.id1 and H2.id = L1.id2) and (H1.id = L2.id2 and H2.id = L2.id1) and H1.name < H2.name;

-- 4 - Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.
select distinct H.name, H.grade
from highschooler H
where H.id not in (select id1 from likes union select id2 from likes)
order by H.grade, H.name;

-- 5 - For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.
select H1.name, H1.grade, H2.name, H2.grade
from highschooler H1, highschooler H2, likes L
where (H1.id = L.id1 and H2.id = L.id2) and H2.id not in (select id1 from likes);

-- 6 - Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade.
select H.name, H.grade
from highschooler H
where H.id not in (
select distinct H1.id
from highschooler H1, highschooler H2, friend F
where H1.id = F.id1 and H2.id = F.id2 and H1.grade <> H2.grade)
order by H.grade, H.name;

-- 7 - For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!).
-- For all such trios, return the name and grade of A, B, and C.
select distinct H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
from highschooler H1, highschooler H2, highschooler H3, likes L, friend F1, friend F2
where (H1.id = L.id1 and H2.id = L.id2) and (H1.id = F1.id1 and H3.id = F1.id2) and (H2.id = F2.id1 and H3.id = F2.id2) and H2.id not in (select id2 from friend where id1 = H1.id);

-- 8 - Find the difference between the number of students in the school and the number of different first names.
select count(id) - count(distinct name)
from highschooler;

-- 9 - Find the name and grade of all students who are liked by more than one other student.
select H.name, H.grade
from highschooler H
where (select count(distinct id1) from likes L where L.id2 = H.id) > 1;

-- Social-Network query exercises extras
-- 1 - For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.
select H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
from highschooler H1, highschooler H2, highschooler H3, likes L1, likes L2
where (H1.id = L1.id1 and H2.id = L1.id2) and (H2.id = L2.id1 and H3.id = L2.id2) and H1.id <> H3.id;

-- 2 - Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades.
select H.name, H.grade
from highschooler H
where H.id not in (
select distinct H1.id
from highschooler H1, highschooler H2, friend F
where H1.id = F.id1 and H2.id = F.id2 and H1.grade = H2.grade);

-- 3 - What is the average number of friends per student? (Your result should be just one number.)
select avg(F1.friends)
from (
select count(F.id2) as friends
from friend F
group by F.id1) as F1;

-- 4 - Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend.
select count(F2.id2)
from friend F1, friend F2
where F1.id1 in (select id from highschooler where name = 'Cassandra') and F2.id1 = F1.id2;

-- 5 - Find the name and grade of the student(s) with the greatest number of friends.
select H.name, H.grade
from highschooler H, friend F1
where H.id = F1.id1
group by F1.id1
having count(F1.id2) = (
select max(C)
from (
select count(F.id2) as C
from friend F
group by F.id1) as F1);

-- Movie-Rating modification exercises
-- 1 - Add the reviewer Roger Ebert to your database, with an rID of 209.
insert into reviewer values (209, 'Roger Ebert');

-- 2 - For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.)
update movie
set year = year + 25
where mID in (select mID from (
select mID, avg(stars) as avgStars
from rating R
group by mID
having avgStars >= 4) as C);

-- 3 - Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.
delete from rating
where mID in (select mID from movie where year > 2000 or year < 1970) and stars < 4;

-- Social-Network modification exercises
-- 1 - It's time for the seniors to graduate. Remove all 12th graders from Highschooler.
delete from highschooler
where grade = 12;

-- 2 - If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.
delete from likes
where id1 in (select L.id1
from highschooler H1, highschooler H2, friend F, likes L
where (H1.id = F.id1 and H2.id = F.id2) and (H1.id = L.id1 and H2.id = L.id2) and H1.id not in (select L1.id2 from likes L1 where L1.id1 = H2.id)) and 
id2 in (select L.id2
from highschooler H1, highschooler H2, friend F, likes L
where (H1.id = F.id1 and H2.id = F.id2) and (H1.id = L.id1 and H2.id = L.id2) and H1.id not in (select L1.id2 from likes L1 where L1.id1 = H2.id));

-- 3 - For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C.
-- Do not add duplicate friendships, friendships that already exist, or friendships with oneself.
insert into friend
select distinct F1.id1, F2.id2
from friend F1, friend F2
where F1.id2 = F2.id1 and F1.id1 <> F2.id2 and F1.id1 not in (select F3.id1 from friend F3 where F3.id2 = F2.id2);


