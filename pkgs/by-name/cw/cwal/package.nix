{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  imagemagick,
  libimagequant,
  luajit,
  makeBinaryWrapper,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cwal";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "nitinbhat972";
    repo = "cwal";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RDtYBgqTG3Ycn1D6QtaHGZVXKxw8UqhzssxXA4temYo=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    makeBinaryWrapper
  ];

  buildInputs = [
    imagemagick
    libimagequant
    luajit
  ];

  postFixup = ''
    wrapProgram $out/bin/cwal \
      --prefix XDG_DATA_DIRS : $out/share
  '';

  meta = {
    description = "Blazing-fast pywal-like color palette generator written in C";
    homepage = "https://github.com/nitinbhat972/cwal";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      gustlik501
      nitinbhat972
    ];

    platforms = lib.platforms.unix;
    mainProgram = "cwal";
  };
})
