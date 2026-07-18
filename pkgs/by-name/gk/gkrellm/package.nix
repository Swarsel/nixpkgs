{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  gettext,
  glib,
  gtk2,
  libice,
  libsm,
  libx11,
  makeDesktopItem,
  pkg-config,
  which,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gkrellm";
  version = "2.5.1";

  src = fetchurl {
    url = "https://gkrellm.srcbox.net/releases/gkrellm-${finalAttrs.version}.tar.bz2";
    hash = "sha256-CJ48HtOYSC5oLJkAtQTqFmphRKbJ+gQecMW7ymsXfmM=";
  };

  # Makefiles are patched to fix references to `/usr/X11R6' and to add
  # `-lX11' to make sure libx11's store path is in the RPATH.
  postPatch = ''
    echo "patching makefiles..."
    for i in Makefile src/Makefile server/Makefile
    do
      sed -i "$i" -e "s|/usr/X11R6|${libx11.dev}|g ; s|-lICE|-lX11 -lICE|g"
    done
  '';

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
    which
    wrapGAppsHook3
  ];

  buildInputs = [
    gettext
    glib
    gtk2
    libx11
    libsm
    libice
  ];

  makeFlags = [ "STRIP=-s" ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "System"
        "Monitor"
      ];

      comment = "The GNU Krell Monitors";
      desktopName = "GKrellM";
      exec = "gkrellm";
      genericName = "System monitor";
      icon = "gkrellm";
      name = "gkrellm";
    })
  ];

  hardeningDisable = [ "format" ];

  installFlags = [
    "DESTDIR=$(out)"
    "PREFIX=''"
  ];

  meta = {
    description = "Themeable process stack of system monitors";

    longDescription = ''
      GKrellM is a single process stack of system monitors which
      supports applying themes to match its appearance to your window
      manager, Gtk, or any other theme.
    '';

    homepage = "https://gkrellm.srcbox.net";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
})
