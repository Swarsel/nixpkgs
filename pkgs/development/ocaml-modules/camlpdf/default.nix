{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  nix-update-script,
  ocaml,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ocaml${ocaml.version}-camlpdf";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "johnwhitington";
    repo = "camlpdf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f3Bm64T27eiIzOY2nwdzMRH68VlyNp2jXpOPyBouSCs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
  ];

  preInstall = ''
    mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib/stublibs
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OCaml library for reading, writing and modifying PDF files";
    homepage = "https://github.com/johnwhitington/camlpdf";
    changelog = "https://github.com/johnwhitington/camlpdf/blob/${finalAttrs.src.rev}/Changes.txt";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ vbgl ];
    broken = lib.versionOlder ocaml.version "4.10";
    teams = with lib.teams; [ ngi ];
  };
})
