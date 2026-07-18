{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "fireflyalgorithm";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "firefly-cpp";
    repo = "FireflyAlgorithm";
    tag = version;
    hash = "sha256-NMmwjKtIk8KR0YXXSXkJhiQsbjMusaLnstUWx0izCNA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'numpy = "^1.26.1"' ""
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "fireflyalgorithm" ];

  meta = {
    description = "Implementation of the stochastic nature-inspired algorithm for optimization";
    homepage = "https://github.com/firefly-cpp/FireflyAlgorithm";
    changelog = "https://github.com/firefly-cpp/FireflyAlgorithm/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ firefly-cpp ];
    mainProgram = "firefly-algorithm";
  };
}
