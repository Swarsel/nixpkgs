{
  lib,
  stdenv,
  fetchFromGitHub,
  camlpdf,
  findlib,
  nix-update-script,
  ocaml,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ocaml${ocaml.version}-cpdf";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "johnwhitington";
    repo = "cpdf-source";
    tag = "v${finalAttrs.version}";
    hash = "sha256-P3CQwYp23URVBDcdnrRAg7gAsOMIifwraIcFSJh8pd0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
  ];

  propagatedBuildInputs = [ camlpdf ];

  preInstall = ''
    mkdir -p $OCAMLFIND_DESTDIR
    mkdir -p $out/bin
    cp cpdf $out/bin
    mkdir -p $out/share/
    cp -r doc $out/share
    cp cpdfmanual.pdf $out/share/doc/cpdf/
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (ocaml.meta) platforms;
    description = "PDF Command Line Tools";
    homepage = "https://www.coherentpdf.com/";
    changelog = "https://github.com/johnwhitington/cpdf-source/blob/${finalAttrs.src.rev}/Changes.txt";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ vbgl ];
    mainProgram = "cpdf";
    broken = lib.versionOlder ocaml.version "4.10";
    teams = with lib.teams; [ ngi ];
  };
})
