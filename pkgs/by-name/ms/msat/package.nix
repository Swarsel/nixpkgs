{ ocamlPackages }:

with ocamlPackages;
buildDunePackage {
  inherit (msat) version src;
  pname = "msat-bin";

  buildInputs = [
    camlzip
    containers
    msat
  ];

  meta = msat.meta // {
    description = "SAT solver binary based on the msat library";
    mainProgram = "msat";
  };
}
