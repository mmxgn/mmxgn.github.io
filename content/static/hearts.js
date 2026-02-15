// Floating hearts animation for Beici link
document.addEventListener('DOMContentLoaded', function() {
  // Find the Beici link by its href
  const beiciLink = document.querySelector('a[href="https://beiciliang.github.io/"]');

  if (beiciLink) {
    beiciLink.style.position = 'relative';
    beiciLink.style.display = 'inline-block';

    beiciLink.addEventListener('mouseenter', function() {
      createHeart(this);
    });

    // Create hearts periodically while hovering
    let heartInterval;
    beiciLink.addEventListener('mouseenter', function() {
      heartInterval = setInterval(() => createHeart(this), 200);
    });

    beiciLink.addEventListener('mouseleave', function() {
      clearInterval(heartInterval);
    });
  }

  function createHeart(element) {
    const heart = document.createElement('span');
    heart.textContent = '♥';
    heart.className = 'floating-heart';

    // Random horizontal offset
    const offsetX = (Math.random() - 0.5) * 40;
    heart.style.left = `calc(50% + ${offsetX}px)`;

    element.appendChild(heart);

    // Remove heart after animation completes
    setTimeout(() => {
      heart.remove();
    }, 2000);
  }
});
