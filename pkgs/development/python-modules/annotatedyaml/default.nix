{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  poetry-core,
  propcache,
  pytest-asyncio,
  pytest-codspeed,
  pytest-cov-stub,
  pytestCheckHook,
  pyyaml,
  setuptools,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "annotatedyaml";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "annotatedyaml";
    tag = "v${version}";
    hash = "sha256-+4H3StCZ58TDV6LSXyeC6+Vn56W19+bIO4AdsJEfHI0=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-codspeed
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    cython
    poetry-core
    setuptools
  ];

  dependencies = [
    propcache
    pyyaml
    voluptuous
  ];

  pyproject = true;
  pythonImportsCheck = [ "annotatedyaml" ];

  meta = {
    description = "Annotated YAML that supports secrets for Python";
    homepage = "https://github.com/home-assistant-libs/annotatedyaml";
    changelog = "https://github.com/home-assistant-libs/annotatedyaml/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
