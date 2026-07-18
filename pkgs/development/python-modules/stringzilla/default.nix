{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytest-repeat,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "stringzilla";
  version = "4.6.2";

  src = fetchFromGitHub {
    owner = "ashvardanian";
    repo = "stringzilla";
    tag = "v${version}";
    hash = "sha256-PAs5j+J3BH23Yk2K0tYvCmz7cTU4djePzUpjsCk8YZs=";
  };

  nativeCheckInputs = [
    numpy
    pytest-repeat
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  enabledTestPaths = [ "scripts/test_stringzilla.py" ];
  pyproject = true;
  pythonImportsCheck = [ "stringzilla" ];

  meta = {
    description = "SIMD-accelerated string search, sort, hashes, fingerprints, & edit distances";
    homepage = "https://github.com/ashvardanian/stringzilla";
    changelog = "https://github.com/ashvardanian/StringZilla/releases/tag/${src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      aciceri
      dotlambda
    ];
  };
}
