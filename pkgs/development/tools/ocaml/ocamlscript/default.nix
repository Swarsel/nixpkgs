{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  ocaml,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-ocamlscript";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "mjambon";
    repo = "ocamlscript";
    rev = "v${version}";
    sha256 = "sha256:10xz8jknlmcgnf233nahd04q98ijnxpijhpvb8hl7sv94dgkvpql";
  };

  patches = [ ./Makefile.patch ];

  nativeBuildInputs = [
    ocaml
    findlib
  ];

  buildFlags = [ "PREFIX=$(out)" ];
  preInstall = "mkdir -p $out/bin";
  createFindlibDestdir = true;
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    inherit (src.meta) homepage;
    inherit (ocaml.meta) platforms;
    description = "Natively-compiled OCaml scripts";
    license = lib.licenses.boost;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "ocamlscript";
    broken = !(lib.versionAtLeast ocaml.version "4.08");
  };
}
