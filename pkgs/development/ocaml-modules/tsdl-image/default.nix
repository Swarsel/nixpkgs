{
  lib,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  buildDunePackage,
  dune-configurator,
  tsdl,
}:

buildDunePackage rec {
  pname = "tsdl-image";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "sanette";
    repo = pname;
    rev = version;
    hash = "sha256-mgTFwkuFJVwJmHrzHSdNh8v4ehZIcWemK+eLqjglw5o=";
  };

  buildInputs = [
    dune-configurator
  ];

  propagatedBuildInputs = [
    SDL2
    SDL2_image
    tsdl
  ];

  duneVersion = "3";

  meta = {
    description = "OCaml SDL2_image bindings to go with Tsdl";
    homepage = "https://github.com/sanette/tsdl-image";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
