{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  # reverse dependencies
  mashumaro,
  pydantic,
}:

buildPythonPackage rec {
  pname = "typing-extensions";
  version = "4.15.0";

  src = fetchFromGitHub {
    owner = "python";
    repo = "typing_extensions";
    tag = version;
    hash = "sha256-3oAlwvNSJ7NhPiHekh4SJI99cPFh29KCCR9314QzsvQ=";
  };

  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "typing_extensions" ];

  passthru.tests = {
    inherit mashumaro pydantic;
  };

  meta = {
    description = "Backported and Experimental Type Hints for Python";
    homepage = "https://github.com/python/typing";
    changelog = "https://github.com/python/typing_extensions/blob/${version}/CHANGELOG.md";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ pmiddend ];
  };
}
