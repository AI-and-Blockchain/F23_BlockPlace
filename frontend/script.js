const ethers = require('ethers');

const canvasFactoryABI = require('./ContractABI/CanvasFactoryABI.json');
const canvasABI = require('./ContractABI/CanvasABI.json');
const blockPlaceTokenABI = require('./ContractABI/BlockPlaceTokenABI.json');

const blockPlaceTokenAddress = '0x15d76B1642414EC8296d2e59F6373eedCc3F352B'; // Deployed address
const canvasAddress = '0xdf67e63aE392be275D1Ad1A6bdeF9e08423241A1';
const canvasFactoryAddress = '0x57eea7f1cef7baba71362a78d8425c81f03aa535';

let blockPlaceTokenContract;
let canvasContract;
let canvasFactoryContract;

let provider;
let signer;

document.addEventListener('DOMContentLoaded', function() {
  startTimer();
  if (typeof window.ethereum !== 'undefined') {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    // Prompt user for account connections
    window.ethereum.request({ method: 'eth_requestAccounts' })
    .then(accounts => {
      signer = provider.getSigner(accounts[0]);
      // Now you can use the signer for transactions
      initBoard(); // Initialize the board after setting up the signer
    })
    .catch(err => {
      console.error('Error:', err);
    });
  } else {
    console.log('Ethereum wallet is not available');
  }
});

function initBoard() {
  blockPlaceTokenContract = new ethers.Contract(blockPlaceTokenAddress, blockPlaceTokenABI, signer);
  canvasContract = new ethers.Contract(canvasAddress, canvasABI, signer);
  canvasFactoryContract = new ethers.Contract(canvasFactoryAddress, canvasFactoryABI, signer);

  const board = document.querySelector('.board');
  const infoBox = document.getElementById('infoBox');

  for (let y = 0; y < 56; y++) {
    for (let x = 0; x < 56; x++) {
      const pixel = document.createElement('div');
      pixel.classList.add('pixel');
      pixel.dataset.x = x;
      pixel.dataset.y = y;
      pixel.id = `pixel-${x}-${y}`;
      pixel.addEventListener('click', function(event) {
        showInfoBox(event, pixel);
      });
      board.appendChild(pixel);
    }
  }
  document.querySelector('#bidAmount').addEventListener('input', function(event) {
    const bidAmount = event.target.value;
    // can't be empty
    if (bidAmount === '') {
      event.target.value = 0;
      return;
    }
    // can't be negative
    if (parseFloat(bidAmount) < 0) {
      event.target.value = 0;
      return;
    }
  });


}

window.selectedPixel = null;

function showInfoBox(event, pixel) {
  const infoBox = document.getElementById('infoBox');
  infoBox.style.display = 'block';
  infoBox.style.left = event.pageX + 'px';
  infoBox.style.top = event.pageY + 'px';

  const x = pixel.dataset.x;
  const y = pixel.dataset.y;
  // Now you have the x and y coordinates of the hovered pixel
  console.log(`Hovered over pixel at x: ${x}, y: ${y}`);

  window.selectedPixel = pixel;
}

function placeBid() {
  const colorCode = document.getElementById('colorCode').value; // Assume format "#RRGGBB"
  const bidAmount = document.getElementById('bidAmount').value; // In ETH

  if (colorCode.match(/^#[0-9a-f]{6}$/i) === null) {
    alert('Invalid color code');
    return;
  }

  let value = ethers.utils.parseEther(bidAmount);
  if (value.toString() === '0') {
    alert('Bid amount must be greater than 0');
    return;
  }

  const r = parseInt(colorCode.slice(1, 3), 16);
  const g = parseInt(colorCode.slice(3, 5), 16);
  const b = parseInt(colorCode.slice(5, 7), 16);

  const x = window.selectedPixel.dataset.x;
  const y = window.selectedPixel.dataset.y;
  
  canvasContract.buyPixel(x, y, r, g, b, {
    value: value
  }).then((tx) => {
    console.log('Transaction sent', tx);
    return tx.wait();
  }).then((receipt) => {
    console.log('Transaction confirmed', receipt);
  }).catch((error) => {
    console.error('Error placing bid:', error);
  });
}

let timerDuration = 15*60;
let timerInterval;
function startTimer() {
  timerInterval = setInterval(() => {
    let minutes = Math.floor(timerDuration / 60);
    let seconds = timerDuration % 60;

    minutes = minutes < 10 ? '0' + minutes : minutes;
    seconds = seconds < 10 ? '0' + seconds : seconds;

    document.getElementById('timer').innerText = `${minutes}:${seconds}`;

    if (timerDuration <= 0) {
      console.log(`Timer Duration: ${timerDuration}`);
      clearInterval(timerInterval);
      //sendBoardData();
    }
    timerDuration--;
  }, 1000);
}


window.placeBid = placeBid;

setInterval(async () => {
  const { chainId } = await provider.getNetwork()
  if (chainId !== 11155111) {
    await window.ethereum.request({
      method: 'wallet_switchEthereumChain',
      params: [{ chainId: '0xAA36A7' }], // chainId must be in hexadecimal numbers
    });
  }
}, 2000)
