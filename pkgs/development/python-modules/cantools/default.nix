{
  lib,
  argparse-addons,
  bitstruct,
  buildPythonPackage,
  crccheck,
  diskcache,
  fetchPypi,
  matplotlib,
  parameterized,
  pytest-freezegun,
  pytestCheckHook,
  python-can,
  setuptools,
  setuptools-scm,
  textparser,
}:

buildPythonPackage (finalAttrs: {
  pname = "cantools";
  version = "41.3.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Y5ZbAorAKrG0yGeqIH7Zn5D1WziuEHq+KH19ZtVDXZ8=";
  };

  nativeCheckInputs = [
    parameterized
    pytest-freezegun
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.plot;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    argparse-addons
    bitstruct
    python-can
    crccheck
    diskcache
    textparser
  ];

  optional-dependencies.plot = [ matplotlib ];
  pyproject = true;
  pythonImportsCheck = [ "cantools" ];

  meta = {
    description = "Tools to work with CAN bus";
    homepage = "https://github.com/cantools/cantools";
    changelog = "https://github.com/cantools/cantools/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gray-heron ];
    mainProgram = "cantools";
  };
})
