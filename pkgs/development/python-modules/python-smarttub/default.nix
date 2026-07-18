{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  inflection,
  pyjwt,
  pytest-asyncio,
  pytestCheckHook,
  python-dateutil,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-smarttub";
  version = "0.0.48";

  src = fetchFromGitHub {
    owner = "mdz";
    repo = "python-smarttub";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+iaRZO4jPpVnE8Tj8SwjMUXS3xB7vd/ztRYNE2B48Ro=";
  };

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    aiohttp
    inflection
    pyjwt
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "smarttub" ];

  meta = {
    description = "Python API for SmartTub enabled hot tubs";
    homepage = "https://github.com/mdz/python-smarttub";
    changelog = "https://github.com/mdz/python-smarttub/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
