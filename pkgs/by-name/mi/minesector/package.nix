{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  cmake,
  libtiff,
  libwebp,
  ninja,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "minesector";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "ruuzia";
    repo = "minesector";
    tag = finalAttrs.version;
    hash = "sha256-VMTXZ4CIk9RpE4R9shHPl0R/T7mJUKY2b8Zi0DPW0/Q=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "set(STATIC_LINK" "# set(STATIC_LINK"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libtiff
    libwebp
    SDL2
    SDL2_image
    SDL2_ttf
    SDL2_mixer
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Snazzy Minesweeper-based game built with SDL2";
    homepage = "https://github.com/ruuzia/minesector";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "minesector";
  };
})
