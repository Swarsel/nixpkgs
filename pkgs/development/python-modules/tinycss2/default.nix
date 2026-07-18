{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytest-cov-stub,
  pytestCheckHook,
  webencodings,
}:

buildPythonPackage rec {
  pname = "tinycss2";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "kozea";
    repo = "tinycss2";
    tag = "v${version}";
    hash = "sha256-ZVmdHrqfF5fvBvHLaG2B4m1zek4wfEYArkntWzOqhfM=";
    # for tests
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ flit-core ];
  dependencies = [ webencodings ];
  pyproject = true;

  meta = {
    description = "Low-level CSS parser for Python";
    homepage = "https://github.com/Kozea/tinycss2";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ onny ];
  };
}
