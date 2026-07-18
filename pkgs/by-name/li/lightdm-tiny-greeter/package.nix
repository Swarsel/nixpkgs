{
  lib,
  stdenv,
  fetchFromGitHub,
  config,
  glib,
  gtk3,
  lightdm,
  lightdm-tiny-greeter,
  linkFarm,
  pkg-config,
  wrapGAppsHook3,
  conf ? config.lightdm-tiny-greeter.conf or "",
}:

stdenv.mkDerivation rec {
  pname = "lightdm-tiny-greeter";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "tobiohlala";
    repo = "lightdm-tiny-greeter";
    rev = version;
    sha256 = "08azpj7b5qgac9bgi1xvd6qy6x2nb7iapa0v40ggr3d1fabyhrg6";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    lightdm
    gtk3
    glib
  ];

  buildPhase = ''
    mkdir -p $out/bin $out/share/xgreeters
    make ${pname}
    mv ${pname} $out/bin/.
    mv lightdm-tiny-greeter.desktop $out/share/xgreeters
  '';

  installPhase = ''
    substituteInPlace "$out/share/xgreeters/lightdm-tiny-greeter.desktop" \
      --replace "Exec=lightdm-tiny-greeter" "Exec=$out/bin/lightdm-tiny-greeter"
  '';

  postUnpack = lib.optionalString (conf != "") ''
    cp ${builtins.toFile "config.h" conf} source/config.h
  '';

  passthru.xgreeters = linkFarm "lightdm-tiny-greeter-xgreeters" [
    {
      name = "lightdm-tiny-greeter.desktop";
      path = "${lightdm-tiny-greeter}/share/xgreeters/lightdm-tiny-greeter.desktop";
    }
  ];

  meta = {
    description = "Tiny multi user lightdm greeter";
    homepage = "https://github.com/tobiohlala/lightdm-tiny-greeter";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "lightdm-tiny-greeter";
  };
}
