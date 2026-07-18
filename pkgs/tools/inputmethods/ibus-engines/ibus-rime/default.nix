{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gdk-pixbuf,
  glib,
  ibus,
  libnotify,
  librime,
  pkg-config,
  rime-data,
  symlinkJoin,
  rimeDataPkgs ? [ rime-data ],
}:

stdenv.mkDerivation rec {
  pname = "ibus-rime";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "rime";
    repo = "ibus-rime";
    rev = version;
    sha256 = "sha256-7RyCJpgGMqq5s4ijTDA2aq2CtpnQ1HOwO9aPrizSaSo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    ibus
    libnotify
    librime
  ];

  cmakeFlags = [ "-DRIME_DATA_DIR=${placeholder "out"}/share/rime-data" ];

  postInstall = ''
    cp -r "${rimeDataDrv}/share/rime-data/." $out/share/rime-data/
  '';

  rimeDataDrv = symlinkJoin {
    postBuild = ''
      mkdir -p $out/share/rime-data

      # Ensure default.yaml exists
      [ -e "$out/share/rime-data/default.yaml" ] || touch "$out/share/rime-data/default.yaml"
    '';

    name = "ibus-rime-data";
    paths = rimeDataPkgs;
  };

  meta = {
    description = "Rime input method engine for IBus";
    homepage = "https://rime.im/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ pmy ];
    platforms = lib.platforms.linux;
    isIbusEngine = true;
  };
}
