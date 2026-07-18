{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dethrace";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "dethrace-labs";
    repo = "dethrace";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SGQGErlmsJEhjdvZa2YPJWwNFuZR4RL81W7meilw8t0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    perl
  ];

  buildInputs = [ SDL2 ];

  installPhase = ''
    install -Dm755 dethrace $out/bin/dethrace
  '';

  meta = {
    description = "Reverse engineering the 1997 game Carmageddon";
    homepage = "https://twitter.com/dethrace_labs";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ astro ];
    platforms = lib.platforms.linux;
    mainProgram = "dethrace";
  };
})
