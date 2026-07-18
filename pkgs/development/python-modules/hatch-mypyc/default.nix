{
  lib,
  fetchFromGitHub,
  build,
  buildPythonPackage,
  hatchling,
  mypy,
  pathspec,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "hatch-mypyc";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "ofek";
    repo = "hatch-mypyc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3bIi2tlAcBurWqqPDVTJ1/EU2KTd1XVU97jFOaYtW5U=";
  };

  doCheck = false; # network access

  build-system = [
    hatchling
  ];

  dependencies = [
    hatchling
    mypy
    pathspec
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "hatch_mypyc"
  ];

  meta = {
    description = "Hatch build hook plugin for Mypyc";
    homepage = "https://github.com/ofek/hatch-mypyc";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
