{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
}:
let
  # needed for pkgsStatic
  inherit (buildPackages.buildPackages) ocamlPackages;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "opaline";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "jaapb";
    repo = "opaline";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6htaiFIcRMUYWn0U7zTNfCyDaTgDEvPch2q57qzvND4=";
  };

  strictDeps = true;

  nativeBuildInputs = with ocamlPackages; [
    ocaml
    findlib
    ocamlbuild
  ];

  buildInputs = with ocamlPackages; [ opam-file-format ];
  preInstall = "mkdir -p $out/bin";
  __structuredAttrs = true;
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    inherit (ocamlPackages.ocaml.meta) platforms;
    description = "OPAm Light INstaller Engine";
    homepage = "https://github.com/jaapb/opaline";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "opaline";
  };
})
