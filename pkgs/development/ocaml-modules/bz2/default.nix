{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  bzip2,
  findlib,
  ocaml,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-bz2";
  version = "0.7.0";

  src = fetchFromGitLab {
    owner = "irill";
    repo = "camlbz2";
    rev = version;
    sha256 = "sha256-jBFEkLN2fbC3LxTu7C0iuhvNg64duuckBHWZoBxrV/U=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    ocaml
    findlib
  ];

  propagatedBuildInputs = [
    bzip2
  ];

  preInstall = "mkdir -p $OCAMLFIND_DESTDIR/stublibs";

  autoreconfFlags = [
    "-I"
    "."
  ];

  meta = {
    description = "OCaml bindings for the libbz2 (AKA, bzip2) (de)compression library";
    homepage = "https://gitlab.com/irill/camlbz2";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
    broken = lib.versionOlder ocaml.version "4.02" || lib.versionAtLeast ocaml.version "5.0";
    downloadPage = "https://gitlab.com/irill/camlbz2";
  };
}
