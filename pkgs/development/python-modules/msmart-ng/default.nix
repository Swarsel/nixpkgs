{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  httpx,
  pycryptodome,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "msmart-ng";
  version = "2026.7.0";

  src = fetchFromGitHub {
    owner = "mill1000";
    repo = "midea-msmart";
    tag = version;
    hash = "sha256-OW5++yd+o2KqaFWTo/RiLjK1HO2l9WSDxkiX3lYtaUs=";
  };

  env.CI = true;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    httpx
    pycryptodome
  ];

  pyproject = true;
  pythonImportsCheck = [ "msmart" ];

  meta = {
    description = "Python library for local control of Midea (and associated brands) smart air conditioners";
    homepage = "https://github.com/mill1000/midea-msmart";
    changelog = "https://github.com/mill1000/midea-msmart/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      hexa
      emilylange
    ];

    mainProgram = "msmart-ng";
  };
}
