{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "pinboard";
  version = "2.1.9";

  src = fetchFromGitHub {
    owner = "lionheart";
    repo = "pinboard";
    rev = version;
    sha256 = "sha256-+JWr2QmdqASK/X10U0ZOZ95K2ctWceSW167raxZjIW4=";
  };

  # tests require an API key
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Python wrapper for Pinboard.in";
    homepage = "https://github.com/lionheart/pinboard.py";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ djanatyn ];
    mainProgram = "pinboard";
  };
}
