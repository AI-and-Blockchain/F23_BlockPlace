'''
!pip install ftfy regex tqdm
!pip install git+https://github.com/openai/CLIP.git
%pylab inline
'''

import torch
import clip
from PIL import Image

#Defines the cosine similarity between image and text
#imageis in 224x224
def cosine_similarity(image, text):
    image = preprocess(image).unsqueeze(0).to(device)
    image_features = clip_model.encode_image(image)

    text = clip.tokenize([text]).to(device)
    text_features = clip_model.encode_text(text)

    image_norm = image_features / image_features.norm(dim=-1, keepdim=True)
    text_norm = text_features / text_features.norm(dim=-1, keepdim=True)

    return (image_norm * text_norm).sum()

# CPU
# device = "cpu"
# GPU or CPU
device = "cuda" if torch.cuda.is_available() else "cpu"

#print (clip.available_models() )

clip_model, preprocess = clip.load("ViT-B/32", device=device)


#Open & convert the image from a 56x56 image to a 224x224 image

picture = Image.open("Cat Pixel Art Tail.png")
#picture.show()
picture = picture.resize((56*4,56*4),1)
#picture.show()

prompt = "Garfield"
print("prompt:",prompt," \nScore:",cosine_similarity(picture, prompt))
