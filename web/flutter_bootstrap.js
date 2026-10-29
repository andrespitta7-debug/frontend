{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    
    // Remover el splash screen retro una vez el motor esté listo
    const splash = document.getElementById('sysquest-splash');
    if (splash) {
      splash.style.transition = 'opacity 0.25s ease-out';
      splash.style.opacity = '0';
      setTimeout(() => {
        if (splash.parentNode) {
          splash.parentNode.removeChild(splash);
        }
      }, 250);
    }

    await appRunner.runApp();
  }
});
