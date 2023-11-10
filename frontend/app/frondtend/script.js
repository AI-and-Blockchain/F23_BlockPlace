let selectedColor = '#ff0000'; // Default color

document.addEventListener("DOMContentLoaded", function() {
  const board = document.getElementById('pixel-board');
  const colorPicker = document.getElementById('color-picker');
  
  // Initialize the pixel board
  for(let i = 0; i < 56 * 56; i++) {
    let pixel = document.createElement('div');
    pixel.classList.add('pixel');
    pixel.addEventListener('click', function() {
      this.style.backgroundColor = selectedColor;
    });
    board.appendChild(pixel);
  }

  // Handle color selection from the color picker
  colorPicker.addEventListener('input', function() {
    selectedColor = this.value;
  });

  colorPicker.addEventListener('change', function() {
    selectedColor = this.value;
  });
});
