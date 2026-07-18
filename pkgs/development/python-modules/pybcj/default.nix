{
  lib,
  buildPythonPackage,
  fetchFromCodeberg,
  hypothesis,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pybcj";
  version = "1.0.3";

  src = fetchFromCodeberg {
    owner = "miurahr";
    repo = "pybcj";
    tag = "v${version}";
    hash = "sha256-ExSt7E7ZaVEa0NwAQHU0fOaXJW9jYmEUUy/1iUilGz8=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "bcj"
  ];

  meta = {
    description = "BCJ (Branch-Call-Jump) filter for Python";
    homepage = "https://codeberg.org/miurahr/pybcj";
    changelog = "https://codeberg.org/miurahr/pybcj/src/tag/v${version}/Changelog.rst#v${version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      pitkling
      PopeRigby
    ];
  };
}
