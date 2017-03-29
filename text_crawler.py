import argparse
import urllib2
import bs4
import time
import json
import io
import codecs

# choose which website you would like to crawl ('aidscare', 'aidsorg' or 'jinde')
website = 'jinde'

root_url_aidscare = 'http://www.aidscarechina.org'
root_url_aidsorg = 'http://www.aids.org.cn'
root_url_jinde = 'http://www.jinde.org'

# util functions for website "aidscare"

def get_url_aidscare(num):
    return root_url_aidscare + '/show_news.asp?id=' + str(num)

def get_data_aidscare(url):
  dataFlag = False
  dataList = []
  page = urllib2.urlopen(url)
  soup = bs4.BeautifulSoup(page.read())
  cells = soup.findAll('tr', {"class": "news_txt"})
  if cells:
    dataFlag = True
    dataList = cells[0].get_text()
  return dataFlag, dataList

# util functions for website "aidsorg"

def get_url_aidsorg(num):
    return root_url_aidsorg + '/cms/aidslist/info?id=' + str(num)

def get_data_aidsorg(url):
  dataFlag = False
  dataList = []
  page = urllib2.urlopen(url)
  soup = bs4.BeautifulSoup(page.read())
  cells = soup.findAll('div', {"class": "news_bd"})
  if cells:
    dataFlag = True
    dataList = cells[0].get_text()
  return dataFlag, dataList

# util functions for website "jinde"

def get_url_jinde(num):
    return root_url_jinde + '/Content/News/show/id/' + str(num)

def get_data_jinde(url):
  dataFlag = False
  dataList = []
  page = urllib2.urlopen(url)
  soup = bs4.BeautifulSoup(page.read())
  cells = soup.findAll('div', {"class": "news-body line-180 font-18"})
  if cells:
    dataFlag = True
    dataList = cells[0].get_text()
  return dataFlag, dataList

# main function

if __name__=='__main__':
  if website == 'aidscare':
    outfile = codecs.open('text_aidscare.txt', 'w', 'utf-8')
    for num in range(1, 650):
      dataList = []
      url = get_url_aidscare(num)
      start = time.time()
      dataFlag, dataList = get_data_aidscare(url)
      end = time.time()
      print dataFlag, 'use: %.2f s' % (end - start)
      if dataFlag:
        jsonData = json.dumps(dataList, ensure_ascii=False, indent=2)
        json.dump(jsonData, outfile, ensure_ascii=False, indent=2)
        outfile.write('\n\n')
  elif website == 'aidsorg':
    outfile = codecs.open('text_aidsorg.txt', 'w', 'utf-8')
    for num in range(1, 5000):
      dataList = []
      url = get_url_aidsorg(num)
      start = time.time()
      dataFlag, dataList = get_data_aidsorg(url)
      end = time.time()
      print dataFlag, 'use: %.2f s' % (end - start)
      if dataFlag:
        jsonData = json.dumps(dataList, ensure_ascii=False, indent=2)
        json.dump(jsonData, outfile, ensure_ascii=False, indent=2)
        outfile.write('\n\n')
  else:
    outfile = codecs.open('text_jinde.txt', 'w', 'utf-8')
    for num in range(1, 2400):
      dataList = []
      url = get_url_jinde(num)
      start = time.time()
      dataFlag, dataList = get_data_jinde(url)
      end = time.time()
      print dataFlag, 'use: %.2f s' % (end - start)
      if dataFlag:
        jsonData = json.dumps(dataList, ensure_ascii=False, indent=2)
        json.dump(jsonData, outfile, ensure_ascii=False, indent=2)
        outfile.write('\n\n')
