{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiohttp-sse-client2,
  aresponses,
  awesomeversion,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  mashumaro,
  pytest-asyncio,
  pytestCheckHook,
  syrupy,
}:

buildPythonPackage rec {
  pname = "pysmlight";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "smlight-tech";
    repo = "pysmlight";
    tag = "v${version}";
    hash = "sha256-/FL1iRQAOb+4AdrRpRRkt8NsHpQt4fHfg6qO+aUUZeo=";
  };

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytestCheckHook
    syrupy
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    aiohttp
    aiohttp-sse-client2
    awesomeversion
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysmlight" ];

  meta = {
    description = "Library implementing API control of the SMLIGHT SLZB-06 LAN Coordinators";
    homepage = "https://github.com/smlight-tech/pysmlight";
    changelog = "https://github.com/smlight-tech/pysmlight/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
