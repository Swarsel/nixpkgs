{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "stringly";
  version = "1.0b3";

  src = fetchFromGitHub {
    owner = "evalf";
    repo = "stringly";
    tag = "v${version}";
    hash = "sha256-OAATONkok9M2pVoChtwWMPPU/bhAxGf+BFawy9g3iZI=";
  };

  doCheck = false; # no tests
  build-system = [ flit-core ];
  dependencies = [ typing-extensions ];
  pyproject = true;
  pythonImportsCheck = [ "stringly" ];

  meta = {
    description = "Stringly: Human Readable Object Serialization";
    homepage = "https://github.com/evalf/stringly";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.Scriptkiddi ];
  };
}
