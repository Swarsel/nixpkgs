{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  plover,
  pytestCheckHook,
  setuptools,
  wheel,
}:

buildPythonPackage (finalAttrs: {
  pname = "plover-python-dictionary";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "opensteno";
    repo = "plover_python_dictionary";
    tag = finalAttrs.version;
    hash = "sha256-4li8WjriJdeLbu+JANuVOb9ejBGusHBm+AaLxyy91A0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    plover
  ];

  pyproject = true;

  pythonImportsCheck = [
    "plover_python_dictionary"
  ];

  meta = {
    description = "Python dictionaries support for Plover";
    homepage = "https://github.com/opensteno/plover_python_dictionary";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      pandapip1
      ShamrockLee
    ];
  };
})
