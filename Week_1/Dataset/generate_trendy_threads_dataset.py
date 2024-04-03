import random
import string
import csv
from faker import Faker # Faker library for generating realistic data. Remember to pip install faker before using it


fake = Faker()

# Generate 1000 rows for both product and customer tables
num_rows = 1000

# Generate 5000 rows for only sales transaction table
num_rows_sales = 5000

# Define product categories

categories = {
    "Tops": ["T-shirts", "Sweaters", "Blouses"],
    "Bottoms": ["Jeans", "Pants", "Skirts"],
    "Dresses" :["Peplum", "Tunic", "Empire"],
    "Shoes": ["Formal", "Casual", "Sneakers"],
    "Accessories": ["Hats", "Bags", "Scarves"]
}

def generate_product():
  category = random.choice(list(categories.keys()))  # Get random category key
  subcategory = random.choice(categories[category])  # Get random subcategory from chosen category
  product_name = f"{subcategory} {random.choice([''.join(random.choices(string.ascii_letters)) for _ in range(3)]).title()}"  # Generate random product name with subcategory prefix
  unit_price = random.uniform(10.00, 100.00)
  return product_name, category, unit_price

# Initialize duplicates_found outside the function
duplicates_found = False

def generate_customer():
  full_name = fake.name()
  first_name, last_name = full_name.split(" ", 1)
  email = fake.email()
  city =fake.city()
  state = fake.state()

  # Generate random string to append to email
  random_suffix = ''.join(random.choice(string.ascii_lowercase + string.digits) for _ in range(6))
  unique_email = f"{email.split('@')[0]}_{random_suffix}@{email.split('@')[1]}"

  # Test for uniqueness (in a loop for this example)
  seen_emails = set()
  duplicates_found = False  # Initialize duplicates_found to False
  for _ in range(10):  # Test 10 times for duplicates
    if unique_email in seen_emails:
      duplicates_found = True
      # If duplicate found, regenerate email
      unique_email = f"{email.split('@')[0]}_{''.join(random.choice(string.ascii_lowercase + string.digits) for _ in range(6))}@{email.split('@')[1]}"
    else:
      seen_emails.add(unique_email)
      break  # Exit loop if unique email found

  return first_name, last_name, city, state, unique_email

# Test generating multiple customers with unique emails
for _ in range(5):
  first_name, last_name, city, state, unique_email = generate_customer()
  print(f"Customer: {first_name} {last_name}, Email: {unique_email}")

# Print if duplicates were encountered during testing
if duplicates_found:
  print("Duplicates were found during email generation.")
else:
  print("No duplicates found in the test set of 10 emails.")


def generate_transaction(customer_id):
  date_time = fake.date_time_between(start_date='-2y', end_date='now')
  quantity = random.randint(1, 3)
  discount = random.uniform(0.00, 0.10)
  product_id = random.randint(1, num_rows)  # Assuming 1000 products
  return (customer_id, product_id, date_time, quantity, discount)

# Generate data
customer_data = [generate_customer() for _ in range(num_rows)]
product_data = [generate_product() for _ in range(num_rows)]
transaction_data = [generate_transaction(random.randint(1, num_rows)) for _ in range(num_rows_sales)]

# Save data to CSV files
with open('customers.csv', 'w', newline='') as csvfile:
  writer = csv.writer(csvfile)
  writer.writerow(['FirstName','LastName', 'City', 'State', 'Email'])
  writer.writerows(customer_data)

with open('products.csv', 'w', newline='') as csvfile:
  writer = csv.writer(csvfile)
  writer.writerow(['ProductName', 'ProductCategory', 'UnitPrice'])
  writer.writerows(product_data)

with open('transactions.csv', 'w', newline='') as csvfile:
  writer = csv.writer(csvfile)
  writer.writerow(['CustomerID', 'ProductID', 'TransactionDate', 'Quantity', 'Discount'])
  writer.writerows(transaction_data)

print("Sample data generated and saved to CSV files!")


