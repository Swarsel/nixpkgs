{
  lib,
  fetchFromGitHub,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage rec {
  pname = "anders";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "groupoid";
    repo = "anders";
    tag = version;
    sha256 = "sha256-8T/+faVsmgghjxC4SkXQ5B6KDuhVO9NdwMvu7UDlk/0=";
  };

  strictDeps = true;
  nativeBuildInputs = [ ocamlPackages.menhir ];
  buildInputs = [ ocamlPackages.zarith ];
  duneVersion = "3";

  meta = {
    description = "Modal Homotopy Type System";
    homepage = "https://homotopy.dev/";
    license = lib.licenses.isc;
    maintainers = [ ];
    mainProgram = "anders";
  };
}
