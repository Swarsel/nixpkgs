{
  lib,
  fetchFromGitHub,
  SDL2,
  SDL2_mixer,
  buildDunePackage,
  dune-configurator,
  tsdl,
}:

buildDunePackage rec {
  pname = "tsdl-mixer";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "sanette";
    repo = pname;
    rev = version;
    hash = "sha256-szuGmLzgGyQExCQwpopVNswtZZdhP29Q1+uNQJZb43Q=";
  };

  buildInputs = [
    dune-configurator
  ];

  propagatedBuildInputs = [
    SDL2
    SDL2_mixer
    tsdl
  ];

  duneVersion = "3";

  meta = {
    description = "SDL2_mixer bindings to go with Tsdl";
    homepage = "https://github.com/sanette/tsdl-mixer";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
