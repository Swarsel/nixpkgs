{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytest-repeat,
  pytestCheckHook,
  setuptools,
  tabulate,
}:

buildPythonPackage rec {
  pname = "simsimd";
  version = "6.5.16";

  src = fetchFromGitHub {
    owner = "ashvardanian";
    repo = "SimSIMD";
    tag = "v${version}";
    hash = "sha256-J4lxmsIgzBhG2MSu2LPDY/5IKTNWEG0fDX1EI4NgLB0=";
  };

  nativeCheckInputs = [
    numpy
    pytest-repeat
    pytestCheckHook
    tabulate
  ];

  build-system = [
    setuptools
  ];

  enabledTestPaths = [
    "scripts/test.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "simsimd"
  ];

  meta = {
    description = "Portable mixed-precision BLAS-like vector math library for x86 and ARM";
    homepage = "https://github.com/ashvardanian/SimSIMD";
    changelog = "https://github.com/ashvardanian/SimSIMD/releases/tag/${src.tag}";

    license = with lib.licenses; [
      asl20
      # or
      bsd3
    ];

    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
