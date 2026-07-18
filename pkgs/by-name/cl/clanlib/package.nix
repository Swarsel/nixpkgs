{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  autoreconfHook,
  fontconfig,
  freetype,
  libGL,
  libpng,
  libxinerama,
  libxrender,
  nix-update-script,
  pkg-config,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clanlib";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "sphair";
    repo = "ClanLib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sRHRkT8NiKVfa9YgP6DYV9WzCZoH7f0phHpoYMnCk98=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    libGL
    libpng
    xorgproto
    freetype
    fontconfig
    alsa-lib
    libxrender
    libxinerama
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross platform toolkit library with a primary focus on game creation";
    homepage = "https://github.com/sphair/ClanLib";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = with lib.platforms; lib.intersectLists linux (x86 ++ arm ++ aarch64 ++ riscv);
  };
})
