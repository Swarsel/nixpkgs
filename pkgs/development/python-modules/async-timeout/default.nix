{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "async-timeout";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "async-timeout";
    tag = "v${version}";
    hash = "sha256-lsSoIv2SnAJbv7V1eRognjv0cCQONwJMlb6fum9wQ/s=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Timeout context manager for asyncio programs";
    homepage = "https://github.com/aio-libs/async_timeout/";
    license = lib.licenses.asl20;
  };
}
