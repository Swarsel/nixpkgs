{
  lib,
  stdenv,
  fetchFromGitHub,
  base64,
  easy-format,
  findlib,
  ocaml,
  sedlex,
  which,
  xmlm,
}:

stdenv.mkDerivation rec {
  pname = "piqi";
  version = "0.6.16";

  src = fetchFromGitHub {
    owner = "alavrik";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-qE+yybTn+kzbY0h8udhZYO+GwQPI/J/6p3LMmF12cFU=";
  };

  patches = [
    ./no-stream.patch
    ./no-ocamlpath-override.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    which
  ];

  propagatedBuildInputs = [
    sedlex
    xmlm
    easy-format
    base64
  ];

  postBuild = "make -C piqilib piqilib.cma";
  createFindlibDestdir = true;

  installTargets = [
    "install"
    "ocaml-install"
  ];

  name = "ocaml${ocaml.version}-${pname}-${version}";

  meta = {
    description = "Universal schema language and a collection of tools built around it";
    homepage = "https://piqi.org";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.maurer ];
    broken = lib.versionAtLeast ocaml.version "5.0";
  };
}
