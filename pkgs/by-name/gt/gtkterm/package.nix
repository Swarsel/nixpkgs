{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk3,
  libgudev,
  meson,
  ninja,
  pcre2,
  pkg-config,
  vte,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtkterm";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "wvdakker";
    repo = "gtkterm";
    rev = finalAttrs.version;
    sha256 = "sha256-oGqOXIu5P3KfdV6Unm7Nz+BRhb5Z6rne0+e0wZ2EcAI=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    vte
    libgudev
    pcre2
  ];

  meta = {
    description = "Simple, graphical serial port terminal emulator";

    longDescription = ''
      GTKTerm is a simple, graphical serial port terminal emulator for
      Linux and possibly other POSIX-compliant operating systems. It
      can be used to communicate with all kinds of devices with a
      serial interface, such as embedded computers, microcontrollers,
      modems, GPS receivers, CNC machines and more.
    '';

    homepage = "https://github.com/wvdakker/gtkterm";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ wentasah ];
    platforms = lib.platforms.linux;
    mainProgram = "gtkterm";
  };
})
