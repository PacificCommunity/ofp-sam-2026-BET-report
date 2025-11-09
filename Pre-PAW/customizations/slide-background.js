// Refactored clean implementation for slide backgrounds
document.addEventListener('DOMContentLoaded', function() {
  console.log('Slide background script loaded');
  
  // Function to apply appropriate classes to slide content and backgrounds
  function updateSlideStyles() {
    // Get current slide
    const currentSlide = Reveal.getCurrentSlide();
    if (!currentSlide) {
      console.log('No current slide found');
      return;
    }
    
    console.log('Current slide classes:', currentSlide.className);
    
    // Handle background classes
    document.body.classList.remove('wide-sidebar-active', 'narrow-sidebar-active');
    
    // Remove all horizontal lines first
    document.querySelectorAll('.horizontal-line').forEach(line => line.remove());
    
    // Remove background pseudo-elements by toggling body classes
    document.body.classList.remove('wide-sidebar-bg', 'narrow-sidebar-bg');
    
    // Apply appropriate styling based on slide type
    if (currentSlide.classList.contains('left-bg-image')) {
      console.log('Applying wide sidebar background');
      // Title slide with wide sidebar
      document.body.classList.add('wide-sidebar-bg');
      document.body.classList.add('wide-sidebar-active');
      
      // Position content with wide margin
      currentSlide.querySelectorAll('.absolute').forEach(el => {
        el.classList.add('content-with-wide-sidebar');
      });
      
    } else if (currentSlide.classList.contains('narrow-left-bg-image')) {
      console.log('Applying narrow sidebar background');
      // Regular slide with narrow sidebar
      document.body.classList.add('narrow-sidebar-bg');
      document.body.classList.add('narrow-sidebar-active');
      
      // Position content with slight margin
      currentSlide.querySelectorAll('.absolute').forEach(el => {
        el.classList.add('content-with-narrow-sidebar');
      });
      
      // Add horizontal line directly to this slide
      const horizontalLine = document.createElement('div');
      horizontalLine.className = 'horizontal-line';
      currentSlide.appendChild(horizontalLine);
    } else {
      console.log('No special background for this slide');
      // No special background - remove all positioning classes
      currentSlide.querySelectorAll('.absolute').forEach(el => {
        el.classList.remove('content-with-wide-sidebar', 'content-with-narrow-sidebar');
      });
    }
    
    console.log('Body classes:', document.body.className);
  }
  
  // Update styles when slides change
  Reveal.on('slidechanged', updateSlideStyles);
  
  // Initial setup
  Reveal.on('ready', function() {
    console.log('Reveal.js ready');
    updateSlideStyles();
    // Trigger resize to ensure proper layout
    window.dispatchEvent(new Event('resize'));
  });
  
  // Update on resize to maintain responsive behavior
  window.addEventListener('resize', function() {
    updateSlideStyles();
  });
});
