{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  cairo,
  glib,
  gtk3,
  libuuid,
  pango,
}:

let
  inherit (stdenv.targetPlatform) system;

  src.x86_64-linux = {
    sha256 = "a1682fbf55e004f1862d6ace31b5220121d20906bdbf308d0a9237b451e4db86";
    urlPath = "x64";
  };

  src.aarch64-linux = {
    sha256 = "sha256-bqGPbvtOM8/A6acDbFJGGf4kzKo/4S/bWcH/XvxVySU=";
    urlPath = "arm64";
  };

in

stdenv.mkDerivation {
  pname = "libsciter";
  version = "4.4.8.23-bis"; # Version specified in GitHub commit title

  src = fetchurl {
    inherit (src.${system}) sha256;
    url = "https://github.com/c-smile/sciter-sdk/raw/524a90ef7eab16575df9496f7e4c374bbd5fb1fe/bin.lnx/${src.${system}.urlPath}/libsciter-gtk.so";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    glib
    cairo
    libuuid
    pango
    gtk3
  ];

  installPhase = ''
    runHook preInstall

    install -m755 -D $src $out/lib/libsciter-gtk.so

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Embeddable HTML/CSS/JavaScript engine for modern UI development";
    homepage = "https://sciter.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ leixb ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
