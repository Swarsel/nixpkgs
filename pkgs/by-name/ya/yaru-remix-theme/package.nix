{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  gnome,
  gnome-themes-extra,
  gtk3,
  meson,
  ninja,
  pkg-config,
  python3,
  sassc,
}:

stdenv.mkDerivation rec {
  pname = "yaru-remix";
  version = "40";

  src = fetchFromGitHub {
    owner = "Muqtxdir";
    repo = "yaru-remix";
    rev = "v${version}";
    sha256 = "0xilhw5gbxsyy80ixxgj0nw6w782lz9dsinhi24026li1xny804c";
  };

  postPatch = "patchShebangs .";

  nativeBuildInputs = [
    meson
    sassc
    pkg-config
    glib
    ninja
    python3
  ];

  buildInputs = [
    gtk3
    gnome-themes-extra
  ];

  dontDropIconThemeCache = true;

  meta = {
    description = "Fork of the Yaru GTK theme";
    homepage = "https://github.com/Muqtxdir/yaru-remix";

    license = with lib.licenses; [
      cc-by-sa-40
      gpl3Plus
      lgpl21Only
      lgpl3Only
    ];

    maintainers = with lib.maintainers; [ hoppla20 ];
    platforms = lib.platforms.linux;
  };
}
