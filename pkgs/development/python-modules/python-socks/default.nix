{
  lib,
  fetchFromGitHub,
  anyio,
  async-timeout,
  buildPythonPackage,
  curio,
  flask,
  pytest-asyncio,
  pytest-trio,
  pytestCheckHook,
  setuptools,
  tiny-proxy,
  trio,
  trustme,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-socks";
  version = "2.8.1";

  src = fetchFromGitHub {
    owner = "romis2012";
    repo = "python-socks";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Eu4xeBZbZvAGfFArMiUlUQQa4yywKWj+azv+OHiKJfU=";
  };

  nativeCheckInputs = [
    anyio
    flask
    pytest-asyncio
    pytest-trio
    pytestCheckHook
    tiny-proxy
    trustme
    yarl
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    trio
    curio
    async-timeout
  ];

  optional-dependencies = {
    anyio = [ anyio ];
    curio = [ curio ];
    trio = [ trio ];
  };

  pyproject = true;
  pythonImportsCheck = [ "python_socks" ];

  meta = {
    description = "Core proxy client (SOCKS4, SOCKS5, HTTP) functionality for Python";
    homepage = "https://github.com/romis2012/python-socks";
    changelog = "https://github.com/romis2012/python-socks/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
