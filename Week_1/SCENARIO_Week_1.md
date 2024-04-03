# Challenge - Week 1: Retail Sales Analysis

## Industry: Retail (E-commerce Clothing Store)

## Scenario:

"Trendy Threads" is a leading online clothing store facing increased competition. To gain a competitive edge, they need to leverage business intelligence to understand customer buying habits and optimize their product offerings. You are a data analyst tasked with analyzing their sales data to answer crucial business questions.

## Sample Dataset:

The provided Python script generates a dataset simulating real-world customer transactions:

- Customers: Contains customer details like name, city, state, and email.
- Products: Includes product name, category (e.g., shirts, pants, dresses), and unit price.
- Sales Transactions: Records individual purchases with transaction date, customer ID, product ID, quantity purchased, and any applied discounts.
  
## Business Cases:

### Beginner (3 cases):

1. Identify the top 5 most popular clothing categories (by total units sold) in the past quarter.
2. Calculate the average order value (total revenue per transaction) for the past month.
3. Find the city with the highest average customer spending.
   
### Intermediate (4 cases):

4. Analyze sales trends for each product category over the past year. Identify any seasonal patterns. (Use window functions)
5. Segment customers based on their purchase frequency (e.g., one-time buyers, frequent buyers). (Use subqueries)
6. Calculate the contribution margin (profit after accounting for variable costs) for each product category.
7. Identify customer churn rate (percentage of customers who haven't made a purchase in the last 6 months).
   
### Advanced (3 cases):
8. Develop a stored procedure to automatically generate a weekly sales report with key metrics like total revenue, average order value, and top-selling products.
9. Use self-joins to analyze product co-purchasing patterns and recommend complementary items for upselling.
10. Cleanse the data by identifying and addressing potential inconsistencies like missing product categories or invalid email addresses.
