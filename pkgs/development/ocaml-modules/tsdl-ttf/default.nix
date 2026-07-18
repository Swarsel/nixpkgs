{
  lib,
  fetchFromGitHub,
  SDL2,
  SDL2_ttf,
  buildDunePackage,
  dune-configurator,
  tsdl,
}:

buildDunePackage rec {
  pname = "tsdl-ttf";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "sanette";
    repo = pname;
    rev = version;
    hash = "sha256-1MGbsekaBoCz4vAwg+Dfzsl0xUKgs8dUEr+OpLopnig=";
  };

  buildInputs = [
    dune-configurator
  ];

  propagatedBuildInputs = [
    SDL2
    SDL2_ttf
    tsdl
  ];

  duneVersion = "3";

  meta = {
    description = "SDL2_ttf bindings for Ocaml with Tsdl";
    homepage = "https://github.com/sanette/tsdl-ttf";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
