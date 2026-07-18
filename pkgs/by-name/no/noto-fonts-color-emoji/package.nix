{
  lib,
  fetchFromGitHub,
  buildPackages,
  cairo,
  imagemagick,
  nototools,
  pkg-config,
  pngquant,
  python3Packages,
  stdenvNoCC,
  which,
  zopfli,
}:

stdenvNoCC.mkDerivation rec {
  pname = "noto-fonts-color-emoji";
  version = "2.051";

  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = "noto-emoji";
    rev = "v${version}";
    hash = "sha256-qngf8t5fLYAOtO2GMhbMv7I34RO/eYfNawW+Th/uaYQ=";
  };

  postPatch = ''
    patchShebangs *.py
    patchShebangs third_party/color_emoji/*.py
    # remove check for virtualenv, since we handle
    # python requirements using python.withPackages
    sed -i '/ifndef VIRTUAL_ENV/,+2d' Makefile
    # Make the build verbose so it won't get culled by Hydra thinking that
    # it somehow got stuck doing nothing.
    sed -i 's;\t@;\t;' Makefile
  '';

  strictDeps = true;

  nativeBuildInputs = [
    imagemagick
    zopfli
    nototools
    pngquant
    which
    python3Packages.fonttools
  ];

  buildFlags = [ "BYPASS_SEQUENCE_CHECK=True" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/noto
    cp NotoColorEmoji.ttf $out/share/fonts/noto
    runHook postInstall
  '';

  depsBuildBuild = [
    buildPackages.stdenv.cc
    pkg-config
    cairo
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Color emoji font";
    homepage = "https://github.com/googlefonts/noto-emoji";

    license = with lib.licenses; [
      ofl
      asl20
    ];

    maintainers = with lib.maintainers; [
      mathnerd314
      sternenseemann
    ];

    platforms = lib.platforms.all;
  };
}
