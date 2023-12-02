use music;
select * from album2;

# to display senior most employee based on level
select * from employee order by levels desc limit 1;


#to display country with their total invoices
select count(*) as number, billing_country from invoice group by billing_country order by number desc;


#display top 3 values of total invoices
select * from invoice order by total desc limit 3;


# to display one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select billing_city, SUM(total) as invoice_total from invoice group by billing_city order by invoice_total desc;


#who is best customer? the customer who has spent the most money will be declared the best customer. query that returns that returns a person who has spent 
# the most money
select customer_id, sum(total) as total_invoice from invoice group by customer_id order by total_invoice desc;
  #############################                                   OR                     ###############################
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total 
from customer join invoice on(customer.customer_id=invoice.customer_id)
group by customer.customer_id order by total desc limit 1;


#Write query to return email, first name, last name & genre of all rock music listeners. return your list ordered alphabetically
#by email starting with A
select distinct customer.email,customer.first_name, customer.last_name, genre.genre_id, genre.name 
from customer join invoice on(customer.customer_id=invoice.customer_id) join invoice_line on(invoice.invoice_id=invoice_line.invoice_id)
join track on(invoice_line.track_id=track.track_id) 
join genre on(track.genre_id=genre.genre_id) where genre.name='Rock' order by customer.email asc;


#query that returns the artist name and track count of the top 10 rock bands
select artist.artist_id,count(artist.artist_id) as total_songs from track join album2 on(album2.album_id=track.album_id)
join artist on(artist.artist_id=album2.artist_id)
join genre on(genre.genre_id=track.genre_id)
where genre.name like 'Rock'
group by artist.artist_id 
order by total_songs desc
limit 10;
select name from artist where artist_id=1;


#return all the track names that have song length longer than the average song length. return the name and milliseconds for each track.alter
#order by the song length with the longest songs list first
select name, milliseconds from track where milliseconds > (select sum(milliseconds)/count(*) from track) order by milliseconds desc;
select sum(milliseconds)/count(*) from track;
#######################                    OR              ###############################
select name, milliseconds from track where milliseconds > (select avg(milliseconds) from track) order by milliseconds desc;


#Find how much amount spent by each customer on artists? Query to return customer name, artist id and total spent
##########          CTE's -----------------------COMMON TABLE EXPRESSIONS------------------CREATES TEMPORARY TABLE       #######################################
WITH best_selling_artist as(
 select artist.artist_id as artist_id, 
 SUM(invoice_line.unit_price*invoice_line.quantity) as total_sales
 from invoice_line 
 join track on(track.track_id=invoice_line.track_id) 
 join album2 on(album2.album_id=track.album_id)
 join artist on(artist.artist_id=album2.artist_id)
 group by 1
 order by 2  desc
 )
select c.customer_id, c.first_name, c.last_name,bsa.artist_id,
SUM(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on(il.invoice_id=i.invoice_id)
join track t on t.track_id=il.track_id
join album2 alb on alb.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=alb.artist_id
group by 1,2,3,4
order by 5 desc;


#Query to find out the most popular music genre for each country . Deteriminig the most popular genre as the genre with the hisghest amount of purchases
# query that returns each country with the top genre
with popular_genre as
(
select count(invoice_line.quantity) as purchase, customer.country, genre.name, genre.genre_id,
ROW_NUMBER() OVER(PARTITION BY customer.country order by count(invoice_line.quantity) desc) as rowno
from invoice_line
join invoice on(invoice.invoice_id=invoice_line.invoice_id)
join customer on(customer.customer_id=invoice.customer_id) 
join track on(track.track_id=invoice_line.track_id)
join genre on(genre.genre_id=track.genre_id)
group by 2,3,4
order by 2 asc, 1 desc
)
select * from popular_genre where rowno<=1;
######################                         OR               #####################################
with RECURSIVE
SALES_per_country as
(
select count(*) as purchase, customer.country, genre.name, genre.genre_id
from invoice_line
join invoice on(invoice.invoice_id=invoice_line.invoice_id)
join customer on(customer.customer_id=invoice.customer_id) 
join track on(track.track_id=invoice_line.track_id)
join genre on(genre.genre_id=track.genre_id)
group by 2,3,4
order by 2 
),
max_genre_per_country as(select max(purchase) as max_genre_number, country
from sales_per_country
group by 2
order by 2)

select sales_per_country.*
from sales_per_country
join max_genre_per_country on sales_per_country.country = max_genre_per_country.country
where sales_per_country.purchase = max_genre_per_country.max_genre_number;



###query that determines the customer that has spent the most on music for each country. query that returns the country 
#along with top customer and how much they spent. 
with customer_with_country as
(
select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending,
ROW_NUMBER() OVER(PARTITION BY billing_country order by sum(total) desc) as RowNo
from invoice
join customer on customer.customer_id=invoice.customer_id
group by 1,2,3,4
order by 4 asc, 5 desc)
select * from customer_with_country where RowNo <=1;










