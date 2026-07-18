{
  lib,
  stdenv,
  fetchFromGitHub,
  audacious-plugins,
  meson,
  ninja,
  pkg-config,
  qt6,
  withPlugins ? false,
}:

stdenv.mkDerivation rec {
  pname = "audacious";
  version = "4.6.1";

  src = fetchFromGitHub {
    owner = "audacious-media-player";
    repo = "audacious";
    rev = "${pname}-${version}";
    hash = "sha256-f1ugxM57dYDDq/G+16bXs6++KXnaLwT+mcPY0R371tY=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
  ];

  mesonFlags = [
    "-Dgtk=false"
    "-Dbuildstamp=NixOS"
  ];

  postInstall = lib.optionalString withPlugins ''
    ln -s ${audacious-plugins}/lib/audacious $out/lib
    ln -s ${audacious-plugins}/share/audacious/Skins $out/share/audacious/
  '';

  meta = {
    description = "Lightweight and versatile audio player";
    homepage = "https://audacious-media-player.org";

    license = with lib.licenses; [
      bsd2
      bsd3 # https://github.com/audacious-media-player/audacious/blob/master/COPYING
      gpl2
      gpl3
      lgpl2Plus # http://redmine.audacious-media-player.org/issues/46
    ];

    maintainers = with lib.maintainers; [
      ramkromberg
      thiagokokada
    ];

    platforms = lib.platforms.linux;
    mainProgram = "audacious";
    downloadPage = "https://github.com/audacious-media-player/audacious";
  };
}
