{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fftwSinglePrec,
  glib,
  gperftools,
  libacars,
  libconfig,
  liquid-dsp,
  nix-update-script,
  pkg-config,
  soapysdr-with-plugins,
  sqlite,
  versionCheckHook,
  zeromq,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dumphfdl";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "szpajder";
    repo = "dumphfdl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kbUCHddhkM3Cj39ac5GQM3hCihRERnzWdELtnHjaIgg=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    fftwSinglePrec
    liquid-dsp
    glib
    libconfig
    soapysdr-with-plugins
    sqlite
    zeromq
    gperftools
    libacars
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Decoder for Multichannel HFDL aircraft communication";

    longDescription = ''
      HFDL (High Frequency Data Link) is a protocol used for radio communications
      between aircraft and ground stations. It is used to carry ACARS and AOC messages as well as
      CPDLC (Controller-Pilot Data Link Communications) and ADS-C.
    '';

    homepage = "https://github.com/szpajder/dumphfdl";
    changelog = "https://github.com/szpajder/dumphfdl/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.mafo ];
    platforms = with lib.platforms; linux ++ darwin;
    badPlatforms = lib.platforms.darwin;
    mainProgram = "dumphfdl";
  };
})
