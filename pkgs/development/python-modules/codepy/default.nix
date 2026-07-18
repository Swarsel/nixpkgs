{
  lib,
  fetchFromGitHub,
  boost,
  buildPythonPackage,
  cgen,
  hatchling,
  numpy,
  platformdirs,
  pytestCheckHook,
  pytools,
  typing-extensions,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "codepy";
  version = "2025.1";

  src = fetchFromGitHub {
    owner = "inducer";
    repo = "codepy";
    tag = "v${version}";
    hash = "sha256-PHIC3q9jQlRRoUoemVtyrl5hcZXMX28gRkI5Xpk9yBY=";
  };

  doCheck = false; # tests require boost setup for ad hoc module compilation
  build-system = [ hatchling ];

  dependencies = [
    cgen
    numpy
    platformdirs
    pytools
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "codepy" ];

  meta = {
    description = "Generate and execute native code at run time, from Python";
    homepage = "https://github.com/inducer/codepy";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
