{
  lib,
  stdenv,
  fetchurl,
  undmg,
}:

stdenv.mkDerivation rec {
  pname = "pika";
  version = "0.0.12";

  src = fetchurl {
    url = "https://github.com/superhighfives/${pname}/releases/download/${version}/Pika-${version}.dmg";
    sha256 = "sha256-hcP2bETEx9RQW43I9nvdRPi9lbWwKW6mhRx5H6RxhjM=";
  };

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p "$out/Applications/Pika.app"
    cp -R . "$out/Applications/Pika.app"
  '';

  sourceRoot = "Pika.app";

  meta = {
    description = "Open-source colour picker app for macOS";
    homepage = "https://superhighfives.com/pika";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arkivm ];
    platforms = lib.platforms.darwin;
  };
}
