{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  mashumaro,
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyvesync";
  version = "3.4.2";

  src = fetchFromGitHub {
    owner = "webdjoe";
    repo = "pyvesync";
    tag = finalAttrs.version;
    hash = "sha256-pJv5CMsM82ZUfc9ZuuAut+wHp2pMHOeOqMcH1jg3uRs=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
    requests
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    mashumaro
    python-dateutil
  ]
  ++ mashumaro.optional-dependencies.orjson;

  pyproject = true;
  pythonImportsCheck = [ "pyvesync" ];

  meta = {
    description = "Python library to manage Etekcity Devices and Levoit Air Purifier";
    homepage = "https://github.com/webdjoe/pyvesync";
    changelog = "https://github.com/webdjoe/pyvesync/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
