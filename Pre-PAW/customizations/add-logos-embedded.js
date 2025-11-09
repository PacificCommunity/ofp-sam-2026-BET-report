window.addEventListener('load', function() {
    // Base64 encoded SPC logo for self-contained HTML
    const SPC_LOGO_BASE64 = '__SPC_LOGO_PLACEHOLDER__';
    
    // Create a container for logos
    var logoDiv = document.createElement('div');
    logoDiv.className = 'multiple-logos';
    
    // Create logo images - use base64 data if available, fallback to path
    var logo1 = document.createElement('img');
    if (SPC_LOGO_BASE64 !== '__SPC_LOGO_PLACEHOLDER__') {
        logo1.src = SPC_LOGO_BASE64;
    } else if (window.quartoLogos && window.quartoLogos.logo1) {
        logo1.src = window.quartoLogos.logo1;
    } else {
        logo1.src = 'static/spc-logo.png';
    }
    logo1.alt = 'SPC Logo';
    logo1.style.maxHeight = '100px';
    logo1.style.width = 'auto';
    
    // Add logos to container
    logoDiv.appendChild(logo1);
    
    // Add the logo container to the reveal container
    var revealContainer = document.querySelector('.reveal');
    if (revealContainer) {
        revealContainer.appendChild(logoDiv);
    }
    
    // Update logo positioning on slide change
    function updateLogoPosition() {
        // This is handled by CSS classes now
        // Just ensuring logos are visible
        logoDiv.style.display = 'flex';
    }
    
    // Set up event listeners for slide changes if Reveal is available
    if (typeof Reveal !== 'undefined') {
        Reveal.on('slidechanged', updateLogoPosition);
        Reveal.on('ready', updateLogoPosition);
    }
});
