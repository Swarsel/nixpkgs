{
  lib,
  fetchFromGitHub,
  haskellPackages,
}:

haskellPackages.mkDerivation {
  pname = "lngen";
  version = "0-unstable-2024-10-22";

  src = fetchFromGitHub {
    owner = "plclub";
    repo = "lngen";
    rev = "c034c8d95264e6a5d490bc4096534ccd54f0d393";
    hash = "sha256-XzcB/mNXure6aZRmwgUWGHSEaknrbP8Onk2CisVuhiw=";
  };

  # Fix build on GHC >=9.8.1, where using partial functions was made an error with `-Werror`
  preBuild = ''
    substituteInPlace lngen.cabal --replace-fail "-Werror" "-Werror -Wwarn=x-partial"
  '';

  description = "Tool for generating Locally Nameless definitions and proofs in Coq, working together with Ott";
  executableHaskellDepends = with haskellPackages; [ base ];
  homepage = "https://github.com/plclub/lngen";
  isExecutable = true;
  isLibrary = true;

  libraryHaskellDepends = with haskellPackages; [
    base
    syb
    parsec
    containers
    mtl
  ];

  license = lib.licenses.mit;
  mainProgram = "lngen";
  maintainers = with lib.maintainers; [ chen ];
}
