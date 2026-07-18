{
  libplasma,
  mkKdeDerivation,
  pkg-config,
  qtvirtualkeyboard,
  wayland-protocols,
}:
mkKdeDerivation {
  pname = "plasma-keyboard";
  # themes rely on non-global imports
  dontQmlLint = true;

  extraBuildInputs = [
    qtvirtualkeyboard

    libplasma

    wayland-protocols
  ];

  extraNativeBuildInputs = [
    pkg-config
  ];

  qtWrapperArgs = [
    # FIXME: fix this upstream? This should probably be XDG_DATA_DIRS
    "--set QT_VIRTUALKEYBOARD_HUNSPELL_DATA_PATH /run/current-system/sw/share/hunspell/"
  ];
}
