from eth_utils import address
from web3 import Web3
from multiprocessing import Pool
# RPC_URL = "https://1rpc.io/sepolia"
RPC_URL = "https://ethereum-sepolia.publicnode.com"
web3 = Web3(Web3.HTTPProvider(RPC_URL))
import json

with open("canvasABI.json") as f:
    CANVAS_ABI = json.load(f)

def loadPixel(address, x, y):
    contract = web3.eth.contract(address=address, abi=CANVAS_ABI)

    r, g, b, _, _ = contract.functions.pixels(x, y).call()

    return [r,g,b]

# returns pixels as [r,g,b] array
# in a 56x56 array:
# pixels[row][col] = [r,g,b]
# tested to take about 30 seconds for this canvas size
def loadCanvas(address):
    args = []

    for y in range(56):
        for x in range(56):
            args.append((address, x, y))
    
    # load each pixel in a row in parallel
    with Pool(56) as p:
        results = p.starmap(loadPixel, args)

    pixels = []
    for y in range(56):
        row = []
        for x in range(56):
            row.append(results[x*56+y])
        pixels.append(row)

    return pixels

if __name__ == '__main__':
    print(loadCanvas(input("Address:")))