window.addEventListener('load', function() {
  console.log('Flutter app loaded');
  
  // Check if Flutter loaded properly
  if (window.flutterSplashRemoved === false) {
    console.warn('Splash screen was not removed by Flutter');
    setTimeout(function() {
      if (window.flutterSplashRemoved === false) {
        removeSplashFromWeb();
      }
    }, 1000);
  }
});

window.addEventListener('unhandledrejection', function(event) {
  console.error('Unhandled promise rejection:', event.reason);
  if (!window.flutterSplashRemoved) {
    setTimeout(() => removeSplashFromWeb(), 1000);
  }
});