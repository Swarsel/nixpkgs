{
  lib,
  stdenv,
  fetchFromGitHub,
  file,
  findlib,
  ocaml,
  which,
}:

stdenv.mkDerivation rec {
  pname = "magic";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "Chris00";
    repo = "ocaml-magic";
    tag = "v${version}";
    sha256 = "sha256-rsBMx68UDqmVVsyeZCxIS97A/0JCBM/JOgh60ly1uSs=";
  };

  nativeBuildInputs = [ which ];

  buildInputs = [
    ocaml
    findlib
  ];

  propagatedBuildInputs = [ file ];
  createFindlibDestdir = true;

  meta = {
    description = "Bindings for libmagic";
    homepage = "https://github.com/Chris00/ocaml-magic";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
  };
}
