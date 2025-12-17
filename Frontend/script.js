// After (through CloudFront):
const API_URL = '/api/views';  // Relative path, uses same domain
const roleElement = document.getElementById('role-text');

async function updateViewCount() {
  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    document.getElementById('view-count').textContent = data.views;
  } catch (error) {
    console.error('Error:', error);
  }
}

// Typewriter Effect
const textToType = "DevOps & Cloud Engineer";
let idx = 0;

function typeWriter() {
    if (idx < textToType.length) {
        roleElement.innerHTML += textToType.charAt(idx);
        idx++;
        setTimeout(typeWriter, 100);
    }
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    updateViewCount();
    typeWriter();
});
