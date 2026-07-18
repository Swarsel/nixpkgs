{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  bchunk,
  bzip2,
  callPackage,
  cdparanoia,
  cmake,
  dialog,
  fetchpatch,
  ffmpeg,
  libpng,
  makeWrapper,
  p7zip,
  pkg-config,
  python3,
  runCommand,
  unzip,
  zlib,
}:

let
  stratagus = callPackage ./stratagus.nix { };

  dataDownload = fetchurl {
    sha256 = "0yxgvf8xpv1w2bjmny4a38pa3xcdgqckk9abj21ilkc5zqzqmm9b";
    url = "https://archive.org/download/warcraft-ii-tides-of-darkness_202105/Warcess.zip";
  };

  data =
    runCommand "warcraft2"
      {
        buildInputs = [
          unzip
          bchunk
          p7zip
        ];

        meta.license = lib.licenses.unfree;
      }
      ''
        unzip ${dataDownload} "Warcraft.II.Tides.of.Darkness/Warcraft II - Tides of Darkness (1995)/games/WarcrafD/cd/"{WC2BTDP.img,WC2BTDP.cue}
        bchunk "Warcraft.II.Tides.of.Darkness/Warcraft II - Tides of Darkness (1995)/games/WarcrafD/cd/"{WC2BTDP.img,WC2BTDP.cue} WC2BTDP
        rm -r Warcraft.II.Tides.of.Darkness
        7z x WC2BTDP01.iso
        rm WC2BTDP*.{iso,cdr}
        cp -r DATA $out
      '';

in
stdenv.mkDerivation rec {
  inherit (stratagus) version;
  pname = "wargus";

  src = fetchFromGitHub {
    owner = "wargus";
    repo = "wargus";
    tag = "v${version}";
    sha256 = "sha256-rU2uMhk7Hx9hrLR/iH2tHkJ2z4cVmJB3ISlvY6dfQKU=";
  };

  patches = [
    (fetchpatch {
      sha256 = "sha256-9FgflNyqZUrBY1prOahicnjslMxxUrK2bLspfGeZ6Os=";
      # "change to cmake_minimum_required(VERSION 3.5) to fix CI"
      url = "https://github.com/Wargus/wargus/commit/e89e121edadaf3ab365263c68b5baec305a5c65f.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
    ffmpeg
  ];

  buildInputs = [
    zlib
    bzip2
    libpng
  ];

  cmakeFlags = [
    "-DSTRATAGUS=${stratagus}/games/stratagus"
    "-DSTRATAGUS_INCLUDE_DIR=${stratagus.src}/gameheaders"
  ];

  postInstall = ''
    makeWrapper $out/games/wargus $out/bin/wargus \
      --prefix PATH : ${lib.makeBinPath [ "$out" ]}
    substituteInPlace $out/share/applications/wargus.desktop \
      --replace $out/games/wargus $out/bin/wargus

    $out/bin/wartool -v -r ${data} $out/share/games/stratagus/wargus
    ln -s $out/share/games/stratagus/wargus/{contrib/black_title.png,graphics/ui/black_title.png}
  '';

  meta = {
    description = "Importer and scripts for Warcraft II: Tides of Darkness, the expansion Beyond the Dark Portal, and Aleonas Tales";
    homepage = "https://wargus.github.io/";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.astro ];
    platforms = lib.platforms.linux;
  };
}
