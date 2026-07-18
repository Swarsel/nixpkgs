{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  py,
  pytest,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pytest-random-order";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "jbasko";
    repo = "pytest-random-order";
    tag = "v${version}";
    hash = "sha256-c282PrdXxG7WChnkpLWe059OmtTOl1Mn6yWgMRfCjBA=";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    py
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "random_order" ];

  meta = {
    description = "Randomise the order of tests with some control over the randomness";
    homepage = "https://github.com/jbasko/pytest-random-order";
    changelog = "https://github.com/jbasko/pytest-random-order/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prusnak ];
  };
}
