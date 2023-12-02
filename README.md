# F23_BlockPlace

## Team

Shane Stoll, Tripp Lyons, Aarnav Patel, Yuk Ting Kong

## Background

BlockPlace is an application inspired by r/Place, a subreddit where people could work together to color in a blank canvas one pixel at a time to create art. 

Block Place aims to gameify using Blockchain technology and AI to reward users for creating well-made pixel art.

We issue a prompt that users aim to make pixel art out of (Example: Dogs), and users claim & color pixel tiles via the Smart contract, and users can override already claimed pixels by using more tokens than the previous user. At the end of the canvas time, the image is then sent to OPEN AI's Clip model for judging. If the Model is able to say with confidence that the image represents the prompt, all users whose pixel was used in the final image are rewarded with extra tokens to continue the game.

<img src="https://github.com/AI-and-Blockchain/F23_BlockPlace/assets/72285616/fc5757b8-6768-4357-934a-16afc6c65a45" width="500" height="500">

## How to Run

Check the [Frontend README](/frontend/README.md) for instructions on how to run the frontend.

## Tech Stack

We implement the Smart contracts using Solidity

The Frontend is developed in Javascript using the  Next.js / React Framework

## AI Component & Rationale

We use OpenAI’s CLIP model to use it to score the similarity of the image created by the users against the prompt they are given.

The reason why we use the AI, specifically the CLIP AI model, is that it introduces a 3rd Party judge that all users can trust. Since the CLIP model is open source,  all users are able to view the source code to verify it is unbiased. 

## Blockchain Component & Rationale

The smart contract creates a decentralized bidding system where people can bid on specific pixels to color on the canvas. 

We use blockchain to assist the system in verifying the correct users to reward at the end of a game cycle.

## Sequence Diagram

<img src="https://github.com/AI-and-Blockchain/F23_BlockPlace/assets/72285616/3ab99bf0-4522-4dcf-935b-e024c3943683" width="500" height="500">

## Network Architecture
<img src="https://github.com/AI-and-Blockchain/F23_BlockPlace/assets/72285616/547ca8af-2cca-455b-ae40-26cfd0ef284f" width="750" height="500">

## Contract Addresses

- CanvasFactory: 0x7cf527c4B4B6e3117795bf632C3D00013E0F3f0B
- Other contracts are referenced in the CanvasFactory contract
