create database netflix;

CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);


select * from netflix;

-- 1. Count the number of Movies vs TV Shows
select type, count(*) from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows
select type,rating from
(select type,rating,count(*),
rank() over (partition by type order by count(*)desc) as ranking
from netflix
group by 1,2)
as t1
where ranking =1;
-- 3. List all movies released in a specific year (e.g., 2020)
select title from netflix
where release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
select * from netflix;

select unnest(string_to_array(country,',')) as new_country,
count(show_id) as total_content from netflix
group by 1
order by 2 desc 
limit 5;

-- 5. Identify the longest movie
select * from netflix
where type = 'Movie' and duration = (select max(duration) from netflix);

-- 6. Find content added in the last 5 years
select * from netflix
where to_date(date_added, 'month,dd,yyyy') >= current_date - interval '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from netflix
where director = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons
select * from netflix
where type = 'TV Show' and duration > '5 seasons';

-- 9. Count the number of content items in each genre
select director,count(type) as no_of_content_each_genre from netflix
group by director;

-- 10.Find each year and the average numbers of content release in India on netflix. 
--    return top 5 year with highest avg content release!
select 
extract(year from to_date(date_added, 'month,dd,yyyy')) as year,
count(*),
round(count(*)::numeric/(select count(*) from netflix 
where country = 'India'):: numeric * 100,2) as avg_content_per_year
from netflix
where country = 'India'
group by 1

-- 11. List all movies that are documentaries
select * from netflix
where type = 'Movie' and listed_in = 'Documentaries'

-- 12. Find all content without a director
select * from netflix
where director is null;

-- 13. Find how many movies actor 'Junko Takeuchi' appeared in last 10 years!
select * from netflix 
where casts like '%Junko Takeuchi%'
and 
release_year > extract(year from current_date) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select unnest(string_to_array(casts,',')) as actors,
count(*)as total_content
from netflix
where country = 'India'
group by 1
order by 2 desc
limit 10;

-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--    the description field. Label content containing these keywords as 'Bad' and all other 
--    content as 'Good'. Count how many items fall into each category.
with new_table as (
select *, 
case when 
description like '%kill%' or
description like '%violence%' then 'bad content'
else 'good content'
end category
from netflix )
select category,count(*) as total_content
from new_table
group by 1

