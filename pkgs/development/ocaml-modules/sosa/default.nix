{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  ocaml,
  ocamlbuild,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-sosa";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "hammerlab";
    repo = "sosa";
    rev = "sosa.${version}";
    sha256 = "053hdv6ww0q4mivajj4iyp7krfvgq8zajq9d8x4mia4lid7j0dyk";
  };

  postPatch = lib.optionalString (lib.versionAtLeast ocaml.version "4.07") ''
    for p in functors list_of of_mutable
    do
      substituteInPlace src/lib/$p.ml --replace Pervasives. Stdlib.
    done
  '';

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    ocamlbuild
    findlib
  ];

  buildPhase = "make build";
  doCheck = true;
  createFindlibDestdir = true;

  meta = {
    description = "Sane OCaml String API";
    homepage = "http://www.hammerlab.org/docs/sosa/master/index.html";
    license = lib.licenses.isc;
    maintainers = [ ];
    broken = !(lib.versionOlder ocaml.version "4.02");
  };
}
