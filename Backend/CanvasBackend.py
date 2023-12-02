from eth_utils import address
from web3 import Web3
import os
from solc import compile_standard, install_solc
from dotenv import load_dotenv
import json
import torch
import clip
from PIL import Image
import numpy as np
import load_canvas
import random 
from flask import Flask, jsonify, request, render_template, make_response
from flask_apscheduler import APScheduler
from flask_cors import CORS
from web3.middleware import construct_sign_and_send_raw_middleware

load_dotenv()

private_key = os.getenv("PRIVKEY")

app = Flask(__name__)
CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

web3 = Web3(Web3.HTTPProvider(load_canvas.RPC_URL))
signer = web3.eth.account.from_key(private_key)
web3.middleware_onion.add(construct_sign_and_send_raw_middleware(signer))

imageLocation = 'CanvasResult.png'
acceptence_threshold = .3

baseTimer = 15*60
secondsLeft = baseTimer

with open("ContractABI/CanvasFactoryABI.json") as f:
    CANVAS_FACTORY_ABI = json.load(f)

with open("ContractABI/CanvasABI.json") as f:
    CANVAS_ABI = json.load(f)

canvasFactoryAddress = '0x57Dc56B4a177fd896bC22461D5a9075fCde032E8'
canvasFactoryContract = web3.eth.contract(address=canvasFactoryAddress, abi=CANVAS_FACTORY_ABI)
canvasAddress = canvasFactoryContract.functions.canvas().call()
canvasContract = web3.eth.contract(address=canvasAddress, abi=CANVAS_ABI)

# Choices of prompts for objects to draw. Started with a small sample size
prompts = ["Car","House","Sun","Moon","Boat","Chair","Book","Flower",
           "Robot","Bicycle","Fish","Tree","Apple","Mountain",
           "Clock","Bird","Star","Plane","Cupcake","Hat","Umbrella",
           "Pizza","Rocket","Whale","Rainbow","Camera","Cat"]

prompt = random.choice(prompts)

device = "cuda" if torch.cuda.is_available() else "cpu"
clip_model, preprocess = clip.load("ViT-B/32", device=device)

#generate a 56x56 image from the canvas tiles
def generateImage(canvasAddress):
    print("canvasAddress:", canvasAddress)
    pixel_data = load_canvas.loadCanvas(canvasAddress)
    pixel_data = np.array(pixel_data).transpose(1,0,2)
    print("pixel_data:", pixel_data.shape)
    img = Image.fromarray(pixel_data.astype(np.int8), 'RGB')
    img.save(imageLocation)
    print("image", img)

#flask http request to send frontend the prompt
@app.route('/prompt', methods=['GET'])
def sendPrompt():
    global prompt
    print("Sending Prompt")

    obj = {"prompt": prompt}

    response = make_response(json.dumps(obj))
    response.content_type = 'application/json'
    return response

#send the score to chainlink
@app.route("/score", methods=["GET"])
def sendScore():
    global prompt
    global imageLocation

    score = Judgement(imageLocation, prompt)
    obj = {
        "score": score
    }

    response = make_response(json.dumps(obj))
    response.content_type = 'application/json'
    return response

@app.route("/time", methods=["GET"])
def gettime():
    global secondsLeft
    obj = {
        "time": secondsLeft
    }

    response = make_response(json.dumps(obj))
    response.content_type = 'application/json'
    return response

#Tasks to do at the end of a canvas game cycle
def end():
    global prompt
    global prompts
    global canvasFactoryAddress
    global canvasAddress
    global secondsLeft
    global baseTimer

    createCanvas()
    prompt = random.choice(prompts)
    secondsLeft = baseTimer

import time

#start a new Canvas contract
def createCanvas():
    global canvasFactoryContract
    global canvasAddress
    global canvasContract

    tx = canvasFactoryContract.functions.newCanvas().transact({
        'from': signer.address
    })
    web3.eth.send_transaction(tx)
    time.sleep(30)
    
    canvasAddress = canvasFactoryContract.functions.canvas().call()
    canvasContract = web3.eth.contract(address=canvasAddress, abi=CANVAS_ABI)

#uses the clip-model to produce the cosine-similarity
def cosine_similarity(image, text):
    image = preprocess(image).unsqueeze(0).to(device)
    image_features = clip_model.encode_image(image)

    text = clip.tokenize([text]).to(device)
    text_features = clip_model.encode_text(text)

    image_norm = image_features / image_features.norm(dim=-1, keepdim=True)
    text_norm = text_features / text_features.norm(dim=-1, keepdim=True)

    return (image_norm * text_norm).sum()

#file_location = String of the path to the 56x56 png file
#prompt = String containing the prompt
#returns CLIP AI score of the image & Prompt
def Judgement(file_location,prompt):
    #if image is not of correct format, return 0 (should never happen but just in case)
    if(not file_location.endswith(".png")):
        return 0
    picture = Image.open(file_location)
    picture = picture.resize((56 * 4, 56 * 4), 1)

    score = cosine_similarity(picture, prompt).item()
    print("prompt:", prompt, " \nScore:", score)
    return score

def loadImage():
    generateImage(canvasAddress)

def countdown():
    global secondsLeft
    secondsLeft -= 1
    if secondsLeft <= 0:
        end()

#Flask Server
if __name__ == "CanvasBackend":
    print("Starting Canvas Backend")

    scheduler = APScheduler()
    #scheduler.add_job(id = 'Scheduled Task', func=loadImage, trigger="interval", seconds=120)
    scheduler.add_job(id = 'countdown', func=countdown, trigger="interval", seconds=1)

    scheduler.start()

    #loadImage()

    app.run(debug = True)   
