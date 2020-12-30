/*> (greater than), < (less than), >= (greater than or equal to), <= (less than or equal to), = (equal to), != (not equal to)*/

/*Q1 The Chinook database contains all invoices from the beginning of 2009 till the end of 2013. The employees at Chinook store are interested in seeing all invoices that happened in 2013 only. Using the Invoice table, write a query that returns all the info of the invoices in 2013.*/
SELECT *
FROM Invoice
WHERE InvoiceDate BETWEEN '2013-01-01' AND '2013-12-31';
/*Q2 The Chinook team decided to run a marketing campaign in Brazil, Canada, india, and Sweden. Using the customer table, write a query that returns the first name, last name, and country for all customers from the 4 countries.*/
SELECT FirstName, LastName, Country
FROM Customer
WHERE Country IN ('Brazil', 'Canada', 'India', 'Sweden');
/*Q3 Using the Track and Album tables, write a query that returns all the songs that start with the letter 'A' and the composer field is not empty. Your query should return the name of the song, the name of the composer, and the title of the album.*/
SELECT t.Name SongName, t.Composer ComposerName, a.Title TitleName
FROM Album a
JOIN Track t
ON t.AlbumId = a.AlbumId
WHERE t.Name LIKE 'A%' AND t.Composer IS NOT NULL;
/*Q4 The Chinook team would like to throw a promotional Music Festival for their top 10 customers who have spent the most in a single invoice. Write a query that returns the first name, last name, and invoice total for the top 10 invoices ordered by invoice total descending."*/
SELECT c.FirstName, c.LastName, i.Total
FROM Customer c
JOIN Invoice i
ON i.CustomerId = c.CustomerId
ORDER BY i.Total DESC
LIMIT 10;
