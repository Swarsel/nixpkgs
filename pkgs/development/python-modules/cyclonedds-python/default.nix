{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cyclonedds,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  pythonOlder,
  rich-click,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cyclonedds-python";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "eclipse-cyclonedds";
    repo = "cyclonedds-python";
    tag = version;
    hash = "sha256-MN3Z5gqsD+cr5Awmsia9+uCHL/a2KQP2uMS13rVc1Hw=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
        --replace-fail "pytest-cov" ""
  ''
  + lib.optionalString (!pythonOlder "3.13") ''
    substituteInPlace clayer/pysertype.c \
        --replace-fail "_Py_IsFinalizing()" "Py_IsFinalizing()"
  '';

  buildInputs = [ cyclonedds ];
  env.CYCLONEDDS_HOME = "${cyclonedds.out}";
  env.NIX_CFLAGS_COMPILE = "-Wno-error=discarded-qualifiers";

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  dependencies = [ rich-click ];
  disabled = (!pythonOlder "3.14");

  disabledTests = lib.optionals (!pythonOlder "3.13") [
    "test_dynamic_subscribe_complex"
    "test_dynamic_publish_complex"
  ];

  pyproject = true;

  meta = {
    description = "Python binding for Eclipse Cyclone DDS";
    homepage = "https://github.com/eclipse-cyclonedds/cyclonedds-python";
    changelog = "https://github.com/eclipse-cyclonedds/cyclonedds-python/releases/tag/${version}";
    license = lib.licenses.epl20;
    maintainers = with lib.maintainers; [ kvik ];
  };
}
