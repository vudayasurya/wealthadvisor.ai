import csv
import random
import datetime
import requests
from bs4 import BeautifulSoup 
from faker import Faker

fake = Faker()

# Scrape S&P500 stocks
url = 'https://en.wikipedia.org/wiki/List_of_S%26P_500_companies'
resp = requests.get(url)
soup = BeautifulSoup(resp.text, 'html.parser')

table = soup.find('table', {'class':'wikitable sortable'})

stocks = []
for row in table.find_all('tr')[1:]:
  ticker = row.find_all('td')[0].text
  name = row.find_all('td')[1].text
  stocks.append({'ticker': ticker, 'name': name})

# Cryptocurrencies
cryptos = ['BTC', 'ETH', 'XRP', 'LTC', 'BCH', 'EOS']

# Generate fake app names  
apps = ['Robinhood', 'Webull', 'E*Trade', 'Fidelity'] 

# Generate user data
num_users = 10000

user_ids = [random.randint(100000,1000000) for i in range(num_users)]
names = [fake.name() for i in range(num_users)]
ages = [random.randint(18, 95) for i in range(num_users)]
cities = [fake.city() for i in range(num_users)]

# Write CSV
with open('portfolio.csv', 'w', newline='') as f:
  writer = csv.writer(f)

  writer.writerow(['User ID', 'Ticker', 'Price', 'Name', 'Date', 'App', 'Shares', 'Total Value', 'Current_Investment_Flag'])

  for i in range(num_users):

    for j in range(random.randint(1,10)):
    
      purchase_date = fake.date_between(start_date="-1y", end_date="today")  
      asset = random.choice(stocks + cryptos)
      price = round(random.uniform(10,60000),2)
      shares = random.randint(1,100)
      total_value = price * shares
      
      if asset in cryptos:
        name = asset
      else:
        matches = [s['name'] for s in stocks if s['ticker'] == asset]
        if matches:
          name = matches[0]
        else:
          name = asset

      ticker = asset
      holding_price = price
      
      if random.random() < 0.8:
        current_flag = '1'
      else:
        current_flag = '0'
        
      writer.writerow([user_ids[i], ticker, holding_price, name, purchase_date, random.choice(apps), shares, total_value, current_flag])

print("Generated dummy portfolio dataset!")
