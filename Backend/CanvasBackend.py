from eth_utils import address
from web3 import Web3
import os
from solc import compile_standard, install_solc
from dotenv import load_dotenv
import json
import torch
import clip
from PIL import Image

threshold = .5 #treshold for acceptance

device = "cuda" if torch.cuda.is_available() else "cpu"
clip_model, preprocess = clip.load("ViT-B/32", device=device)

# Function to create canvas
def createCanvas():
    return


#Tasks to do at the end of a canvas game cycle
def end():
    #get signal from frontend that time is up
    return

#Determines if the score is above the treshhold
#True if Yes, False if no
def determinePayout(score):
    return score >= threshold


#uses the clip-model to produce the cosine-similarity
def cosine_similarity(image, text):
    image = preprocess(image).unsqueeze(0).to(device)
    image_features = clip_model.encode_image(image)

    text = clip.tokenize([text]).to(device)
    text_features = clip_model.encode_text(text)

    image_norm = image_features / image_features.norm(dim=-1, keepdim=True)
    text_norm = text_features / text_features.norm(dim=-1, keepdim=True)

    return (image_norm * text_norm).sum()

#file_location = String of the path to the file
#prompt = String containing the prompt
#returns CLIP AI score of the image & Prompt
def Judgement(file_location,prompt):
    #if image is not of correct format, return 0 (should never happen but just in case)
    if(not file_location.endswith(".png")):
        return 0
    
    picture = Image.open(file_location)
    picture = picture.resize((56*4,56*4),1)

    score = cosine_similarity(picture, prompt).item()
    print("prompt:",prompt," \nScore:",score)
    return score

print(Judgement("Cat Pixel Art Tail.png","Pixel cat"))