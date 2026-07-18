{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
  ocamlbuild,
  ocamlify,
  ocamlmod,
}:

stdenv.mkDerivation {
  pname = "ocaml-oasis";
  version = "0.4.11";

  src = fetchurl {
    url = "https://download.ocamlcore.org/oasis/oasis/0.4.11/oasis-0.4.11.tar.gz";
    hash = "sha256-GLc97vTtbpqDM38ks7vi3tZSaLP/cwn8wA0l5X4dwS4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    ocamlmod
    ocamlify
  ];

  buildInputs = [ ocamlbuild ];

  buildPhase = ''
    runHook preBuild
    ocaml setup.ml -build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    ocaml setup.ml -install
    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure
    ocaml setup.ml -configure --prefix $out
    runHook postConfigure
  '';

  createFindlibDestdir = true;

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Configure, build and install system for OCaml projects";
    homepage = "https://github.com/ocaml/oasis";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ vbgl ];
    mainProgram = "oasis";
    broken = lib.versionAtLeast ocaml.version "5.0";
  };
}
