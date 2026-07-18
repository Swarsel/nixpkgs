{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  libGL,
  pkg-config,
  which,
  installTool ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "azimuth";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "mdsteele";
    repo = "azimuth";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N5Ahetw/zOXDrEiR1umQNF6i3yeawavoLceiU+xD//g=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    which
  ];

  buildInputs = [
    libGL
    SDL2
  ];

  makeFlags = [
    "BUILDTYPE=release"
    "PREFIX=${placeholder "out"}"
    "INSTALLTOOL=${if installTool then "true" else "false"}"
  ];

  env.NIX_CFLAGS_COMPILE = toString [ "-Wno-error=maybe-uninitialized" ];
  doCheck = true;
  __structuredAttrs = true;
  checkTarget = "test";
  enableParallelBuilding = true;

  meta = {
    description = "Metroidvania game using only vectorial graphic";

    longDescription = ''
      Azimuth is a metroidvania game, and something of an homage to the previous
      greats of the genre (Super Metroid in particular). You will need to pilot
      your ship, explore the inside of the planet, fight enemies, overcome
      obstacles, and uncover the storyline piece by piece. Azimuth features a
      huge game world to explore, lots of little puzzles to solve, dozens of
      weapons and upgrades to find and use, and a wide variety of enemies and
      bosses to tangle with.
    '';

    homepage = "https://mdsteele.games/azimuth/index.html";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ marius851000 ];
    platforms = lib.platforms.linux;
    mainProgram = "azimuth";
  };

})
