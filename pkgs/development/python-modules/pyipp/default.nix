{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  awesomeversion,
  backoff,
  buildPythonPackage,
  deepmerge,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  syrupy,
  yarl,
}:

buildPythonPackage rec {
  pname = "pyipp";
  version = "0.17.2";

  src = fetchFromGitHub {
    owner = "ctalkington";
    repo = "python-ipp";
    tag = version;
    hash = "sha256-YlIc/FNM3SdYQj0DN0if3R7h0383V5CHGpD7FHErWhA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    awesomeversion
    backoff
    deepmerge
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyipp" ];

  meta = {
    description = "Asynchronous Python client for Internet Printing Protocol (IPP)";
    homepage = "https://github.com/ctalkington/python-ipp";
    changelog = "https://github.com/ctalkington/python-ipp/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
