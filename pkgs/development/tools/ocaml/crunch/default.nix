{
  lib,
  fetchurl,
  buildDunePackage,
  cmdliner,
  ocaml,
  ptime,
}:

buildDunePackage rec {

  pname = "crunch";
  version = "4.0.0";

  src = fetchurl {
    url = "https://github.com/mirage/ocaml-crunch/releases/download/v${version}/crunch-${version}.tbz";
    sha256 = "sha256-k5uNESntbGNMsPnMxvbUSqFwPNBc5gkfLuKgFilEuJs=";
  };

  outputs = [
    "lib"
    "bin"
    "out"
  ];

  buildInputs = [ cmdliner ];
  propagatedBuildInputs = [ ptime ];

  installPhase = ''
    dune install --prefix=$bin --libdir=$lib/lib/ocaml/${ocaml.version}/site-lib/
  '';

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Convert a filesystem into a static OCaml module";
    homepage = "https://github.com/mirage/ocaml-crunch";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "ocaml-crunch";
  };

}
