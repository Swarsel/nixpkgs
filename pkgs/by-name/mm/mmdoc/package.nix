{
  lib,
  stdenv,
  fetchFromGitHub,
  cmark-gfm,
  libfastjson,
  libzip,
  meson,
  ninja,
  pkg-config,
  xxd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mmdoc";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "ryantm";
    repo = "mmdoc";
    rev = finalAttrs.version;
    hash = "sha256-GxGYW10GZvDzeeKy9U9iyGvfN3IM/A/pnQivx8xXhHI=";
  };

  nativeBuildInputs = [
    ninja
    meson
    pkg-config
    xxd
  ];

  buildInputs = [
    cmark-gfm
    libfastjson
    libzip
  ];

  meta = {
    description = "Minimal Markdown Documentation";
    homepage = "https://github.com/ryantm/mmdoc";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ ryantm ];
    platforms = lib.platforms.unix;
    mainProgram = "mmdoc";
  };
})
