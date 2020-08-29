#!/bin/python

from bs4 import BeautifulSoup
from selenium import webdriver
import pandas as pd
import csv

DECIMAL = 1
stocks = ["IBULHSGFIN", "SBIN", "DLF", "TATASTEEL", "JINDALSTEL", "BANDHANBNK", "PFC", "APOLLOTYRE", "CADILAHC", "M%26MFIN", "TATAMOTORS"]
percent_from_strike = 0.15

with open('trades.csv', mode='w') as file:
        file.write("\n")

for s in stocks:
    # url = "https://www1.nseindia.com/live_market/dynaContent/live_watch/option_chain/optionKeys.jsp?symbolCode=7057&symbol={}&symbol={}&instrument=OPTSTK&date=-&segmentLink=17&segmentLink=17".format(s, s)
    url = "https://www1.nseindia.com/live_market/dynaContent/live_watch/option_chain/optionKeys.jsp?segmentLink=17&instrument=OPTSTK&symbol={}&date=24SEP2020".format(s, s)
    browser = webdriver.Chrome("./chromedriver")
    browser.get(url)
    html = browser.page_source
    browser.close()

    soup = BeautifulSoup(html, 'html.parser')

    curr_price = float(soup.find('b').text.strip().split()[1])
    lower = (1-percent_from_strike)*curr_price
    upper = (1+percent_from_strike)*curr_price

    data = []
    columns = []
    table = soup.find('table', id="octable")
    table_head = table.find('thead')
    rows = table_head.find_all('tr')
    cols = rows[1].find_all('th')
    cols = [ele.text.strip() for ele in cols]
    columns = [ele for ele in cols if ele]
    table_body = table.find('tbody')
    rows = table_body.find_all('tr')
    for row in rows[2:-1]:
        cols = row.find_all('td')
        cols = [ele.text.strip().replace(',', '') for ele in cols if ele.text.strip()]
        data.append([float(ele) if ele != '-' else 0 for ele in cols]) # Get rid of empty values
    df = pd.DataFrame(data, columns=columns[1:-1])

    relevant = df[df['Strike Price'].between(lower, upper)]
    put_relevant = df[df['Strike Price'].between(lower, curr_price)]
    call_relevant = df[df['Strike Price'].between(curr_price, upper)]
    relevant = relevant.iloc[:, [4,6,7,8,9,10,11,12,13,14,16]]
    put_relevant = put_relevant.iloc[:, [10,12,13]]
    call_relevant = call_relevant.iloc[:, [7,8,10]]
    put_relevant['AvgPrice'] = (put_relevant["BidPrice"] + put_relevant["AskPrice"])/2
    put_relevant2 = put_relevant.iloc[:, [0,3]].round(DECIMAL)
    call_relevant['AvgPrice'] = (call_relevant["BidPrice"] + call_relevant["AskPrice"])/2
    call_relevant2 = call_relevant.iloc[:, [2, 3]].round(DECIMAL)

    with open('trades.csv', mode='a') as file:
        file.write("{}\n".format(s))
    put_relevant2.to_csv('trades.csv', mode='a', index=False)
    with open('trades.csv', mode='a') as file:
        file.write("{},-,-,-,-,-,-,-,-,CURRENT PRICE\n".format(curr_price))
    call_relevant2.to_csv('trades.csv', mode='a', index=False, header=False)
    with open('trades.csv', mode='a') as file:
        file.write("\n")
        file.write("\n")
        file.write("\n")
        file.write("\n")









