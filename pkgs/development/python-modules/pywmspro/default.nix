{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
}:

buildPythonPackage (finalAttrs: {
  pname = "pywmspro";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "mback2k";
    repo = "pywmspro";
    tag = finalAttrs.version;
    hash = "sha256-V23YvQ2J+Jj0FFhB0Z4h3vwl8Uz5TOX0/T6qox7pj+0=";
  };

  # Package has no tests
  doCheck = false;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    aiofiles
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "wmspro" ];

  meta = {
    description = "Python library for WMS WebControl pro API";
    homepage = "https://github.com/mback2k/pywmspro";
    changelog = "https://github.com/mback2k/pywmspro/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
