{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gobject-introspection,
  gtk3,
  ibus,
  m17n_lib,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

let

  python = python3.withPackages (
    ps: with ps; [
      pygobject3
      dbus-python
    ]
  );

in

stdenv.mkDerivation rec {
  pname = "ibus-typing-booster";
  version = "2.30.6";

  src = fetchFromGitHub {
    owner = "mike-fabian";
    repo = "ibus-typing-booster";
    rev = version;
    hash = "sha256-3Pld7Jz1foCRzjCLOw8P8RnBgL2Q8AUdmhrFOVxj2OE=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    python
    ibus
    gtk3
    m17n_lib
  ];

  preFixup = ''
    gappsWrapperArgs+=(--prefix LD_LIBRARY_PATH : "${m17n_lib}/lib")
  '';

  meta = {
    description = "Completion input method for faster typing";
    homepage = "https://mike-fabian.github.io/ibus-typing-booster/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "emoji-picker";
    isIbusEngine = true;
  };
}
