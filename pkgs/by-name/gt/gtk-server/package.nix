{
  lib,
  stdenv,
  fetchurl,
  glib,
  gtk4,
  libffcall,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtk-server";
  version = "2.4.7";

  src = fetchurl {
    url = "https://www.gtk-server.org/stable/gtk-server-${finalAttrs.version}.tar.gz";
    hash = "sha256-YRvnE4fH5jWITSiMUbtlaOJFKAW0/Alzo1YVDlm8CO8=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    libffcall
    glib
    gtk4
  ];

  preConfigure = ''
    cd src
  '';

  meta = {
    description = "Gtk-server for interpreted GUI programming";
    homepage = "https://www.gtk-server.org/";
    changelog = "https://www.gtk-server.org/notes.txt";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "gtk-server";
  };
})
