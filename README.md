# F23_BlockPlace


BlockPlace was inspirted by r/Place,  a subreddit where people could work together to color in a blank canvas one pixel at a time to create art. 

Block Place aims to gameify using Block-chain Technologu and AI to reward users for creating well made pixel art based.

We issue a prompt that users aim to make pixel art out of (Example: Dogs), and users claim & color pixel tiles via the Smart contract, and users can override already claimed pixels by using more tokens than the previous user. At the end of the canvas time, the image is then sent to OPEN AI's Clip model for judging. If the Model is able to say with confidence that the image represents the prompt, all users who's pixel was used in the final image are rewarded with extra tokens to continue the game.



## Tech Stack

We implement the Smart contracts using Solidity

The Frontend is developed in Javascript using the  Next.js / React Framework

## AI Component & Rationale

We use OpenAI’s CLIP model to use it to score the similarity of the image created by the users against the prompt they are given.

The reason why we use the AI, specifically the CLIP AI model, is that it introdces an 3rd Party judge that all users can trust. Since the CLIP model is open source,  all users are able to view the source code to verify it is unbiased. 


## Blockchain Component & Rationale

The smart contract create a decentralized bidding system where people can bid on specific pixels to color on the canvas. 

We use blockchain to assist the system in verifying the correct users to reward at the end of a game cycle.


## Sequence Diagram
![image](https://github.com/AI-and-Blockchain/F23_BlockPlace/assets/72285616/3ab99bf0-4522-4dcf-935b-e024c3943683)





## Netowrk Architecture

