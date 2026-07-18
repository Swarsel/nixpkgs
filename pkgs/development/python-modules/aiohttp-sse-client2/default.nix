{
  lib,
  fetchFromGitHub,
  aiohttp,
  attrs,
  buildPythonPackage,
  multidict,
  pytest-aiohttp,
  pytestCheckHook,
  setuptools,
  yarl,
}:

buildPythonPackage rec {
  pname = "aiohttp-sse-client2";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "compat-fork";
    repo = "aiohttp-sse-client";
    tag = version;
    hash = "sha256-uF39gpOYzNotVVYQShUoiuvYAhSRex2T1NfuhgwSCR4=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "pytest-runner" ""
  '';

  # tests access the internet
  doCheck = false;

  nativeCheckInputs = [
    pytest-aiohttp
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    attrs
    multidict
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiohttp_sse_client2" ];

  meta = {
    description = "Server-Sent Event python client library based on aiohttp";
    homepage = "https://github.com/compat-fork/aiohttp-sse-client";
    changelog = "https://github.com/compat-fork/aiohttp-sse-client/blob/${src.rev}/README.rst#fork-changelog";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
