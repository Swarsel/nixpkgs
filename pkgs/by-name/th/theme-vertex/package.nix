{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gtk-engine-murrine,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "theme-vertex";
  version = "20170128";

  src = fetchFromGitHub {
    owner = "horst3180";
    repo = "vertex-theme";
    rev = finalAttrs.version;
    sha256 = "0c9mhrs95ahz37djrv176vn41ywvj26ilwmnr1h9171giv6hid98";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  configureFlags = [ "--disable-unity" ];

  postInstall = ''
    mkdir -p $out/share/plank/themes
    cp -r extra/*-Plank $out/share/plank/themes

    mkdir -p $out/share/doc/$pname/Chrome
    cp -r extra/Chrome/*.crx $out/share/doc/$pname/Chrome
    cp -r extra/Firefox $out/share/doc/$pname
    cp AUTHORS README.md $out/share/doc/$pname/
  '';

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Theme for GTK 3, GTK 2, Gnome-Shell, and Cinnamon";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.unix;
  };
})
