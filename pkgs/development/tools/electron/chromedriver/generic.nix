{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  glib,
  libxcb,
  nspr,
  nss,
  unzip,
}:

version: hashes:
let
  pname = "electron-chromedriver";

  meta = {
    description = "WebDriver server for running Selenium tests on Chrome";

    longDescription = ''
      WebDriver is an open source tool for automated testing of webapps across
      many browsers. It provides capabilities for navigating to web pages, user
      input, JavaScript execution, and more. ChromeDriver is a standalone
      server that implements the W3C WebDriver standard. This is
      an unofficial build of ChromeDriver compiled by the Electronjs
      project.
    '';

    homepage = "https://www.electronjs.org/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      liammurphy14
    ];

    platforms = [
      "x86_64-linux"
      "armv7l-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "chromedriver";
    teams = [ lib.teams.electron ];
  };

  fetcher =
    vers: tag: hash:
    fetchurl {
      sha256 = hash;
      url = "https://github.com/electron/electron/releases/download/v${vers}/chromedriver-v${vers}-${tag}.zip";
    };

  tags = {
    aarch64-darwin = "darwin-arm64";
    aarch64-linux = "linux-arm64";
    armv7l-linux = "linux-armv7l";
    x86_64-linux = "linux-x64";
  };

  get = as: platform: as.${platform.system} or (throw "Unsupported system: ${platform.system}");

  common = platform: {
    inherit pname version meta;
    src = fetcher version (get tags platform) (get hashes platform);

    buildInputs = [
      (lib.getLib stdenv.cc.cc)
      glib
      libxcb
      nspr
      nss
    ];
  };

  linux = {
    strictDeps = true;

    nativeBuildInputs = [
      autoPatchelfHook
      unzip
    ];

    installPhase = ''
      runHook preInstall
      unzip $src
      install -m777 -D chromedriver $out/bin/chromedriver
      runHook postInstall
    '';

    __structuredAttrs = true;
    dontBuild = true;
    dontUnpack = true;
  };

  darwin = {
    nativeBuildInputs = [ unzip ];

    # darwin distributions come with libffmpeg dependency + icudtl.dat file
    installPhase = ''
      runHook preInstall
      unzip $src
      install -m777 -D chromedriver $out/bin/chromedriver
      cp libffmpeg.dylib $out/bin/libffmpeg.dylib
      cp icudtl.dat $out/bin/icudtl.dat
      runHook postInstall
    '';

    dontBuild = true;
    dontUnpack = true;
  };
in
stdenv.mkDerivation (
  (common stdenv.hostPlatform) // (if stdenv.hostPlatform.isDarwin then darwin else linux)
)
