{
  lib,
  stdenv,
  fetchFromGitLab,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  cmake,
  fetchpatch,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "infra-arcana";
  version = "23.0.0";

  src = fetchFromGitLab {
    owner = "martin-tornqvist";
    repo = "ia";
    rev = "v${finalAttrs.version}";
    hash = "sha256-b7YRhoQa298fcP4cXlWhLXajjL0M3Mk4Kbb81iH6s5w=";
  };

  # NOTE(netcrns):
  # both needed for cmake 4 update,
  # can be removed after next stable infra-arcana release.
  patches = [
    # Remove CMake minimum version requirement
    (fetchpatch {
      sha256 = "sha256-WaJKcjKQ9Ip46MM4W2lTFu1ev1lutbgXpceWX2KnffI=";
      url = "https://gitlab.com/martin-tornqvist/ia/-/commit/6d82fe8ac58cfb33b65eb1c345d6a73d7c0a300b.patch";
    })
    # Re-add required CMake version, raise to higher version
    (fetchpatch {
      sha256 = "sha256-+GklNdHsywxN8tCciPjRK9/H75hoSp3oh7rIj6J0gMM=";
      url = "https://gitlab.com/martin-tornqvist/ia/-/commit/51ca3d3cf577a159d65799124c3d19b7c6d49057.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{opt/ia,bin}

    # Remove build artifacts
    rm -rf CMake* cmake* compile_commands.json CTest* Makefile
    cp -ra * $out/opt/ia

    # IA uses relative paths when looking for assets
    wrapProgram $out/opt/ia/ia --run "cd $out/opt/ia"
    ln -s $out/opt/ia/ia $out/bin/infra-arcana

    runHook postInstall
  '';

  meta = {
    description = "Lovecraftian single-player roguelike game";

    longDescription = ''
      Infra Arcana is a Roguelike set in the early 20th century. The goal is to
      explore the lair of a dreaded cult called The Church of Starry Wisdom.

      Buried deep beneath their hallowed grounds lies an artifact called The
      Shining Trapezohedron - a window to all secrets of the universe. Your
      ultimate goal is to unearth this artifact.
    '';

    homepage = "https://sites.google.com/site/infraarcana";
    license = lib.licenses.agpl3Plus;
    maintainers = [ lib.maintainers.kenran ];
    platforms = lib.platforms.linux;
    mainProgram = "infra-arcana";
  };
})
