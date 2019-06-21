import json
import time

from web3 import Web3



w3 = Web3(Web3.WebsocketProvider("ws://localhost:9545"))



with open('../build/contracts/Ticketing.json') as json_file:
    abiJson = json.load(json_file)



contractAddress = '0x2ba3fE77842EA424f694c84D642d5189B6Eb168d'
contract = w3.eth.contract(address=contractAddress, abi=abiJson['abi'])


def handle_event(event):
    receipt = w3.eth.waitForTransactionReceipt(event['transactionHash'])
    print(receipt)


def log_loop(event_filter, poll_interval):
    while True:
        for event in event_filter.get_all_entries():
            handle_event(event)
            time.sleep(poll_interval)


event_filter = w3.eth.filter({"address": contractAddress})


log_loop(event_filter, 2)
