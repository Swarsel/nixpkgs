{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
}:
let
  man = fetchurl {
    hash = "sha256-bjD22dpkQZcGR0TwMxdpaed4VZZO2NUOoAw4o66iyS4=";
    url = "https://web.archive.org/web/20230608093053if_/http://www.ansikte.se/ARAGORN/Downloads/aragorn.1";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "aragorn";
  version = "1.2.41";

  src = fetchurl {
    url = "http://www.ansikte.se/ARAGORN/Downloads/aragorn${finalAttrs.version}.c";
    hash = "sha256-kqMcxcCwrRbU17AZkZibd18H0oFd8TX+bj6riPXpf0o=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  buildPhase = ''
    runHook preBuild

    $CC -O3 -ffast-math -finline-functions -o aragorn $src

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin && cp aragorn $out/bin
    installManPage ${man}

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Detects tRNA, mtRNA, and tmRNA genes in nucleotide sequences";
    homepage = "https://www.trna.se/ARAGORN/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.unix;
    mainProgram = "aragorn";
  };
})
