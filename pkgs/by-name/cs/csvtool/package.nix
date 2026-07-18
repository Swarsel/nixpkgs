{ ocamlPackages }:

let
  inherit (ocamlPackages) buildDunePackage csv uutf;
in

buildDunePackage {
  inherit (csv) src version;
  pname = "csvtool";

  buildInputs = [
    csv
    uutf
  ];

  doCheck = true;
  duneVersion = "3";

  meta = csv.meta // {
    description = "Command line tool for handling CSV files";
    mainProgram = "csvtool";
  };
}
