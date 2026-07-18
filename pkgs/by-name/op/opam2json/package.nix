{
  lib,
  stdenv,
  fetchFromGitHub,
  ocamlPackages,
  opam-installer,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "opam2json";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "tweag";
    repo = "opam2json";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-rBGN9TERADPXiehNe1/9emO6QqYPrTwSoMdB+BVEWpM=";
  };

  nativeBuildInputs = with ocamlPackages; [
    ocaml
    findlib
    opam-installer
  ];

  buildInputs = with ocamlPackages; [
    yojson
    opam-file-format
    cmdliner
  ];

  preInstall = ''export PREFIX="$out"'';

  meta = {
    description = "Convert opam file syntax to JSON";
    homepage = "https://github.com/tweag/opam2json";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.balsoft ];
    platforms = lib.platforms.all;
    mainProgram = "opam2json";
  };
})
