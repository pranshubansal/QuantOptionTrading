from bs4 import BeautifulSoup
from selenium import webdriver
import pandas as pd
import csv, requests

op = pd.read_csv("links.csv")
option_list = list(op[op.columns[1]])
url_list = list(op[op.columns[2]])
url = 'https://www.google.com/search?q=moneycontrol+'

with open('stocks.csv', mode='w') as file:
    file.write("Option Symbol,Book Value,Market Value,Book/Market,EPS,Company P/E,Industry P/E\n")

for i, o in enumerate(option_list):
    o_url = url_list[i]
    response = requests.get(o_url)
    soup = BeautifulSoup(response.content, "html.parser")
    market = soup.find(id="div_nse_livebox_wrap").find("span", {"class": "span_price_wrap stprh red_hilight rdclr"})
    if not market:
        market = soup.find(id="div_nse_livebox_wrap").find("span", {"class": "span_price_wrap stprh grn_hilight grnclr"})
    market = market.getText()
    market = float(market) if market != '-' else 0
    book = soup.findAll("div", {"class": "value_txtfr"})[2].getText()
    book = float(book) if book != '-' else 0
    eps = soup.findAll("div", {"class": "value_txtfr"})[6].getText()
    eps = float(eps) if eps != '-' else 0
    ind_pe = soup.findAll("div", {"class": "value_txtfr"})[5].getText()
    ind_pe = float(ind_pe) if ind_pe != '-' else 0
    pe = soup.findAll("div", {"class": "value_txtfr"})[1].getText()
    pe = float(pe) if pe != '-' else 0

    with open('stocks.csv', mode='a') as file:
        print(o)
        file.write("{},{},{},{},{},{},{}\n".format(o, book, market, book/market, eps, pe, ind_pe))






