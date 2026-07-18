{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glib,
  libacars,
  nix-update-script,
  pkg-config,
  sdrplay,
  soapysdr,
  sqlite,
  versionCheckHook,
  zeromq,
  sdrplaySupport ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dumpvdl2";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "szpajder";
    repo = "dumpvdl2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SSCPJ2D5JuMEEDG+8KYoequWCwRJcd6XwZAZSprShy8=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    glib
    soapysdr
    sqlite
    zeromq
    libacars
  ]
  ++ lib.optionals sdrplaySupport [ sdrplay ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "VDL Mode 2 message decoder and protocol analyzer";
    homepage = "https://github.com/szpajder/dumpvdl2";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.mafo ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "dumpvdl2";
  };
})
