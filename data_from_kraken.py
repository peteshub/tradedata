import krakenex
import json
import time
import csv
import sys
import pandas as pd
import pandas.io.json as pandas_json

#since: 1492544985696123884 ETHEUR

def read_recent_trades(kraken_api,currency_pair,last_trade):

    error = []
    last = last_trade

    csv_file = open(currency_pair+'.csv', 'w')
    trades_writer = csv.writer(csv_file)

    while True:
        res = kapi.query_public("Trades", {'pair': currency_pair, 'since': last})

        error = res["error"]
        if not error:
            if last != res["result"]["last"]:
                trades_writer.writerows(res["result"][currency_pair])
                print len(res["result"][currency_pair])
                last = res["result"]["last"]
            print last
        else:
            print error

        time.sleep(2)


if __name__ == '__main__':


    if len(sys.argv) >1:
        currency_pair = sys.argv[1]
    else:
        currency_pair = 'XETHZEUR'

    if len(sys.argv) >2:
        last = sys.argv[2]
    else:
        last = "0"

    kapi = krakenex.API()

    read_recent_trades(kapi,currency_pair,last)

    # result = kapi.query_public("Trades", {'pair': 'XETHZEUR', 'last' : '0'})
    #
    # if result["error"] == []:
    #     print "no error"
    #
    # print result["result"]["XETHZEUR"]
    #print result["result"]["last"]
    #data = pandas_json.json_normalize(result)

    #print data["result.XETHZEUR"][0][0]
