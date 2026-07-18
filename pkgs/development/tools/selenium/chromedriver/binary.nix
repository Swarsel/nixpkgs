{
  lib,
  stdenv,
  chromedriver,
  fetchzip,
  testers,
  unzip,
}:

let
  upstream-info =
    (lib.importJSON ../../../../applications/networking/browsers/chromium/info.json)
    .chromium.chromedriver;

  # See ./source.nix for Linux
  allSpecs = {

    aarch64-darwin = {
      hash = upstream-info.hash_darwin_aarch64;
      system = "mac-arm64";
    };
  };

  spec =
    allSpecs.${stdenv.hostPlatform.system}
      or (throw "missing chromedriver binary for ${stdenv.hostPlatform.system}");

  inherit (upstream-info) version;
in
stdenv.mkDerivation {
  inherit version;
  pname = "chromedriver";

  src = fetchzip {
    inherit (spec) hash;
    url = "https://storage.googleapis.com/chrome-for-testing-public/${version}/${spec.system}/chromedriver-${spec.system}.zip";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    install -m555 -D "chromedriver" $out/bin/chromedriver
  '';

  passthru.tests.version = testers.testVersion { package = chromedriver; };

  meta = {
    description = "WebDriver server for running Selenium tests on Chrome";

    longDescription = ''
      WebDriver is an open source tool for automated testing of webapps across
      many browsers. It provides capabilities for navigating to web pages, user
      input, JavaScript execution, and more. ChromeDriver is a standalone
      server that implements the W3C WebDriver standard.
    '';

    homepage = "https://chromedriver.chromium.org/";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    # Note from primeos: By updating Chromium I also update Google Chrome and
    # ChromeDriver.
    platforms = lib.platforms.darwin;
    mainProgram = "chromedriver";
  };
}
