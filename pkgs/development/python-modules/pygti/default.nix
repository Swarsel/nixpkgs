{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pydantic,
  pytz,
  voluptuous,
}:

buildPythonPackage (finalAttrs: {
  pname = "pygti";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "vigonotion";
    repo = "pygti";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B+jz91xoN7GiU4PnJTG5Kt1eA4ST63d+ZEgRrr9Xio8=";
  };

  # no tests implemented
  doCheck = false;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    aiohttp
    pydantic
    pytz
    voluptuous
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pygti.auth"
    "pygti.exceptions"
    "pygti.gti"
  ];

  meta = {
    description = "Access public transport information in Hamburg, Germany";
    homepage = "https://github.com/vigonotion/pygti";
    changelog = "https://github.com/vigonotion/pygti/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
