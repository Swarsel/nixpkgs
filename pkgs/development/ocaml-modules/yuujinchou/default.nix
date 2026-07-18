{
  lib,
  fetchFromGitHub,
  algaeff,
  buildDunePackage,
  bwd,
  ocaml,
  qcheck-alcotest,
}:

let
  params =
    if lib.versionAtLeast ocaml.version "5.0" then
      {
        version = "5.2.0";

        propagatedBuildInputs = [
          algaeff
          bwd
        ];

        hash = "sha256-DJzXjV5Tjf69FKUiRioeHghks72pOOHYd73vqhmecS8=";
      }
    else
      {
        version = "2.0.0";
        hash = "sha256:1nhz44cyipy922anzml856532m73nn0g7iwkg79yzhq6yb87109w";
      };
in

buildDunePackage rec {
  inherit (params) version;
  pname = "yuujinchou";

  src = fetchFromGitHub {
    inherit (params) hash;
    owner = "RedPRL";
    repo = pname;
    rev = version;
  };

  propagatedBuildInputs = params.propagatedBuildInputs or [ ];
  doCheck = true;
  checkInputs = [ qcheck-alcotest ];
  minimalOCamlVersion = "4.12";

  meta = {
    description = "Name pattern combinators";
    homepage = "https://github.com/RedPRL/yuujinchou";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
