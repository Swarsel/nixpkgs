{
  lib,
  stdenv,
  fetchurl,
  cmake,
  copyDesktopItems,
  gtk3,
  makeDesktopItem,
  ncurses,
  perl,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "putty";
  version = "0.84";

  src = fetchurl {
    hash = "sha256-BgV4Yq4Zjx29IZ0MdJMIDVn2BhlLtQVsVJ40KqAbaf4=";

    urls = [
      "https://the.earth.li/~sgtatham/putty/${version}/${pname}-${version}.tar.gz"
      "ftp://ftp.wayne.edu/putty/putty-website-mirror/${version}/${pname}-${version}.tar.gz"
    ];
  };

  nativeBuildInputs = [
    cmake
    perl
    pkg-config
    copyDesktopItems
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isUnix [
    gtk3
    ncurses
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "GTK"
        "Network"
      ];

      comment = "Connect to an SSH server with PuTTY";
      desktopName = "PuTTY";
      exec = "putty";
      icon = "putty";
      name = "PuTTY SSH Client";
    })
    (makeDesktopItem {
      categories = [
        "GTK"
        "System"
        "Utility"
        "TerminalEmulator"
      ];

      comment = "Start a PuTTY terminal session";
      desktopName = "Pterm";
      exec = "pterm";
      icon = "pterm";
      name = "PuTTY Terminal Emulator";
    })
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Free Telnet/SSH Client";

    longDescription = ''
      PuTTY is a free implementation of Telnet and SSH for Windows and Unix
      platforms, along with an xterm terminal emulator.
      It is written and maintained primarily by Simon Tatham.
    '';

    homepage = "https://www.chiark.greenend.org.uk/~sgtatham/putty/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aprl ];
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };
}
