{
  lib,
  stdenv,
  fetchFromGitHub,
  asio,
  cmake,
  obs-studio,
  qtbase,
  websocketpp,
}:

stdenv.mkDerivation rec {
  pname = "obs-websocket";
  version = "4.9.1-compat";

  src = fetchFromGitHub {
    owner = "obsproject";
    repo = "obs-websocket";
    rev = version;
    sha256 = "sha256-cHsJxoQjwbWLxiHgIa3Es0mu62vyLCAd1wULeZqZsJM=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    asio
    obs-studio
    qtbase
    websocketpp
  ];

  postInstall = ''
    mkdir $out/lib $out/share
    mv $out/obs-plugins/64bit $out/lib/obs-plugins
    rm -rf $out/obs-plugins
    mv $out/data $out/share/obs
  '';

  dontWrapQtApps = true;

  meta = {
    inherit (obs-studio.meta) platforms;
    description = "Legacy websocket 4.9.1 protocol support for OBS Studio 28 or above";
    homepage = "https://github.com/obsproject/obs-websocket";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ flexiondotorg ];
  };
}
