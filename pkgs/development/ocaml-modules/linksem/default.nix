{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  lem,
  ocaml,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-linksem";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "rems-project";
    repo = "linksem";
    rev = version;
    hash = "sha256-7/YfDK3TruKCckMzAPLRrwBkHRJcX1S+AzXHWRxkZPA=";
  };

  nativeBuildInputs = [
    findlib
    ocaml
  ];

  propagatedBuildInputs = [ lem ];
  createFindlibDestdir = true;

  meta = {
    description = "Formalisation of substantial parts of ELF linking and DWARF debug information";
    homepage = "https://github.com/rems-project/linksem";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = ocaml.meta.platforms;
    broken = !(lib.versionAtLeast ocaml.version "4.07");
  };
}
