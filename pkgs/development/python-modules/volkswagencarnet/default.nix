{
  lib,
  fetchFromGitHub,
  aiohttp,
  beautifulsoup4,
  buildPythonPackage,
  freezegun,
  lxml,
  pyjwt,
  pytest-asyncio,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "volkswagencarnet";
  version = "5.4.11";

  src = fetchFromGitHub {
    owner = "robinostlund";
    repo = "volkswagencarnet";
    tag = "v${version}";
    hash = "sha256-Ria6+dlxV0VA7zXb1eL0TgblxlUjRTYYgDaj/727eCA=";
  };

  postPatch = ''
    substituteInPlace tests/conftest.py \
      --replace-fail 'pytest_plugins = ["pytest_cov"]' 'pytest_plugins = []'
  '';

  nativeCheckInputs = [
    freezegun
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    aiohttp
    beautifulsoup4
    lxml
    pyjwt
  ];

  pyproject = true;
  pythonImportsCheck = [ "volkswagencarnet" ];

  meta = {
    description = "Python library for volkswagen carnet";
    homepage = "https://github.com/robinostlund/volkswagencarnet";
    changelog = "https://github.com/robinostlund/volkswagencarnet/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
