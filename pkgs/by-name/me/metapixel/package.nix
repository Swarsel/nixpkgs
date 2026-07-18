{
  lib,
  stdenv,
  fetchFromGitHub,
  giflib,
  libjpeg,
  libpng,
  perl,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "metapixel";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "schani";
    repo = "metapixel";
    rev = "98ee9daa093b6c334941242e63f90b1c2876eb4f";
    sha256 = "0r7n3a6bvcxkbpda4mwmrpicii09iql5z69nkjqygkwxw7ny3309";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libpng
    libjpeg
    giflib
    perl
  ];

  makeFlags = [ "metapixel" ];

  installPhase = ''
    mkdir -p $out/bin
    cp metapixel $out/bin/metapixel
    cp metapixel-prepare $out/bin/metapixel-prepare
    cp metapixel-sizesort $out/bin/metapixel-sizesort
  '';

  meta = {
    description = "Tool for generating photomosaics";
    homepage = "https://github.com/schani/metapixel";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
}
