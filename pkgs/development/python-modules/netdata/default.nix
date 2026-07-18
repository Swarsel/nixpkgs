{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  poetry-core,
  pytest-asyncio,
  pytest-httpx,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "netdata";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "home-assistant-ecosystem";
    repo = "python-netdata";
    tag = finalAttrs.version;
    hash = "sha256-rffqpvqVvCi7CKjDchgRzUWDNxsA7C37UHvbELewR0E=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-httpx
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    httpx
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "netdata" ];

  meta = {
    description = "Python API for interacting with Netdata";
    homepage = "https://github.com/home-assistant-ecosystem/python-netdata";
    changelog = "https://github.com/home-assistant-ecosystem/python-netdata/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
