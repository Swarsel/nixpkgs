{
  chromedriver,
  chromium,
  testers,
}:
chromium.mkDerivation (finalAttrs: {
  installPhase = ''
    install -Dm555 $buildPath/chromedriver.unstripped $out/bin/chromedriver
  '';

  # Kill existing postFixup that tries to patchelf things
  postFixup = null;
  # Build the unstripped target, because stripping in Chromium relies on a prebuilt strip binary
  # that doesn't run on NixOS, and we will strip everything ourselves later anyway.
  buildTargets = [ "chromedriver.unstripped" ];
  name = "chromedriver";
  packageName = "chromedriver";
  requiredSystemFeatures = [ "big-parallel" ];
  passthru.tests.version = testers.testVersion { package = chromedriver; };

  meta = chromium.meta // {
    description = "WebDriver server for running Selenium tests on Chrome";

    longDescription = ''
      WebDriver is an open source tool for automated testing of webapps across
      many browsers. It provides capabilities for navigating to web pages, user
      input, JavaScript execution, and more. ChromeDriver is a standalone
      server that implements the W3C WebDriver standard.
    '';

    homepage = "https://chromedriver.chromium.org/";
    mainProgram = "chromedriver";
  };
})
