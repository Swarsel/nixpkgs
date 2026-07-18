{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "pyuptimerobot";
  version = "25.0.0";

  src = fetchFromGitHub {
    owner = "ludeeus";
    repo = "pyuptimerobot";
    tag = version;
    hash = "sha256-Fa/65IANK/LP2AaD6hLVH+Jau0swCwd/iBQXVcle6Y0=";
  };

  postPatch = ''
    # Upstream doesn't set version in the repo
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0"' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    aresponses
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ hatchling ];
  dependencies = [ aiohttp ];
  disabled = pythonOlder "3.14";
  pyproject = true;
  pythonImportsCheck = [ "pyuptimerobot" ];

  meta = {
    description = "Python API wrapper for Uptime Robot";
    homepage = "https://github.com/ludeeus/pyuptimerobot";
    changelog = "https://github.com/ludeeus/pyuptimerobot/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
