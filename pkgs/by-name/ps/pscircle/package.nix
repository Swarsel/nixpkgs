{
  lib,
  stdenv,
  fetchFromGitLab,
  cairo,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pscircle";
  version = "1.4.0";

  src = fetchFromGitLab {
    owner = "mildlyparallel";
    repo = "pscircle";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bqbQBNscNfoqXprhoFUnUQO88YQs9xDhD4d3KHamtG0=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  buildInputs = [
    cairo
  ];

  meta = {
    description = "Visualize Linux processes in a form of a radial tree";
    homepage = "https://gitlab.com/mildlyparallel/pscircle";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.ldesgoui ];
    platforms = lib.platforms.linux;
    mainProgram = "pscircle";
  };
})
