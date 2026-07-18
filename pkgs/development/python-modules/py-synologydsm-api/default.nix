{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  awesomeversion,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  syrupy,
}:

buildPythonPackage rec {
  pname = "py-synologydsm-api";
  version = "2.10.4";

  src = fetchFromGitHub {
    owner = "mib1185";
    repo = "py-synologydsm-api";
    tag = "v${version}";
    hash = "sha256-r2f/fVcDg9zDjTBKupkNQD4zQbeTKvZB7AWyncrRKH8=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    syrupy
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    aiohttp
    awesomeversion
  ];

  pyproject = true;
  pythonImportsCheck = [ "synology_dsm" ];

  meta = {
    description = "Python API for Synology DSM";
    homepage = "https://github.com/mib1185/py-synologydsm-api";
    changelog = "https://github.com/mib1185/py-synologydsm-api/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ uvnikita ];
    mainProgram = "synologydsm-api";
  };
}
