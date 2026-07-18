{
  lib,
  fetchhg,
  gcc14Stdenv,
  gtk3,
  json_c,
  libpulseaudio,
  meson,
  ninja,
  pkg-config,
  wayland,
  wrapGAppsHook3,
}:

gcc14Stdenv.mkDerivation {
  pname = "rootbar";
  version = "unstable-2024-08-07";

  src = fetchhg {
    url = "https://hg.sr.ht/~scoopta/rootbar";
    rev = "36333af9fd8d";
    sha256 = "sha256-CpORCSJyHZhcK14EhjxoPt/h0026NU5J/kicL1dX96o=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    json_c
    libpulseaudio
    wayland
  ];

  meta = {
    description = "Bar for wlroots-based Wayland compositors";

    longDescription = ''
      Root Bar is a bar for wlroots-based Wayland compositors such as Sway and
      was designed to address the lack of good bars for Wayland.
    '';

    homepage = "https://hg.sr.ht/~scoopta/rootbar";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "rootbar";
    broken = gcc14Stdenv.hostPlatform.isDarwin;
  };
}
