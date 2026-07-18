{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  cssutils,
  lxml,
  nltk,
  pytest-lazy-fixture,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycaption";
  version = "2.2.28";

  src = fetchFromGitHub {
    owner = "pbs";
    repo = "pycaption";
    tag = finalAttrs.version;
    hash = "sha256-BXDCjUqJVuVCehusrk5j4+yZTimnmOcHMWheWJJoJOo=";
  };

  nativeCheckInputs = [
    pytest-lazy-fixture
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    lxml
    cssutils
  ];

  optional-dependencies = {
    transcript = [ nltk ];
  };

  pyproject = true;

  meta = {
    description = "Closed caption converter";
    homepage = "https://github.com/pbs/pycaption";
    changelog = "https://github.com/pbs/pycaption/blob/${finalAttrs.src.tag}/docs/changelog.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
