
document.addEventListener('DOMContentLoaded', function() {
  const board = document.querySelector('.board');
  const infoBox = document.getElementById('infoBox');

  for (let i = 0; i < 56 * 56; i++) {
      const pixel = document.createElement('div');
      pixel.classList.add('pixel');
      pixel.addEventListener('mouseover', function(event) {
          showInfoBox(event, pixel);
      });
      board.appendChild(pixel);
  }
});

function showInfoBox(event, pixel) {
  const infoBox = document.getElementById('infoBox');
  infoBox.style.display = 'block';
  infoBox.style.left = event.pageX + 'px';
  infoBox.style.top = event.pageY + 'px';
}

function placeBid() {
  const colorCode = document.getElementById('colorCode').value;
  const bidAmount = document.getElementById('bidAmount').value;
  console.log('Color Code:', colorCode, 'Bid Amount:', bidAmount);
  // Here, you would add the logic to handle the bid
}
