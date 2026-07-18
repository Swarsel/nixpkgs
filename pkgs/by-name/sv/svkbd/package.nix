{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxft,
  libxi,
  libxinerama,
  libxtst,
  pkg-config,
  writeText,
  conf ? null,
  layout ? "mobile-intl",
  patches ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  inherit patches;
  pname = "svkbd";
  version = "0.4.2";

  src = fetchurl {
    url = "https://dl.suckless.org/tools/svkbd-${finalAttrs.version}.tar.gz";
    hash = "sha256-bZQyGeMzMUdYY0ZmdKB2CFhZygDc6UDlTU4kdx+UZoA=";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || lib.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) ''
      cp ${configFile} config.def.h
    '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libx11
    libxft
    libxi
    libxinerama
    libxtst
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "LAYOUT=${layout}"
  ];

  meta = {
    description = "Simple virtual keyboard";
    homepage = "https://tools.suckless.org/x/svkbd/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.linux;
    mainProgram = "svkbd-${layout}";
  };
})
