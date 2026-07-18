{
  lib,
  fetchFromGitHub,
  beancount,
  buildPythonPackage,
  pytest-bdd,
  pytestCheckHook,
  regex,
  setuptools,
}:

buildPythonPackage rec {
  pname = "beancount-plugin-utils";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "Akuukis";
    repo = "beancount_plugin_utils";
    rev = "v${version}";
    hash = "sha256-oyfL2K/sS4zZ7cq1P36h0dTcW1m5GUyQ9+IyZGfpb2E=";
  };

  nativeCheckInputs = [
    pytest-bdd
    pytestCheckHook
    regex
  ];

  build-system = [ setuptools ];
  dependencies = [ beancount ];

  enabledTestPaths = [
    "tests/"
  ];

  pyproject = true;
  pytestFlags = [ "--fixtures" ];
  pythonImportsCheck = [ "beancount" ];

  meta = {
    description = "Utils for beancount plugin writers - BeancountError, mark, metaset, etc";
    homepage = "https://github.com/Akuukis/beancount_plugin_utils";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ alapshin ];
  };
}
