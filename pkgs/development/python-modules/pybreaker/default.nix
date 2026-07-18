{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fakeredis,
  flit-core,
  pybreaker,
  pytestCheckHook,
  redis,
  tornado,
}:

buildPythonPackage rec {
  pname = "pybreaker";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "danielfm";
    repo = "pybreaker";
    tag = "v${version}";
    hash = "sha256-Cxer6EDfi4fvs7XENwpUUMcCiRX6eDNJz0s57l9U+zQ=";
  };

  nativeCheckInputs = [
    fakeredis
    pytestCheckHook
    tornado
  ];

  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "pybreaker" ];

  meta = {
    description = "Python implementation of the Circuit Breaker pattern";
    homepage = "https://github.com/danielfm/pybreaker";
    changelog = "https://github.com/danielfm/pybreaker/blob/${src.tag}/CHANGELOG";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
