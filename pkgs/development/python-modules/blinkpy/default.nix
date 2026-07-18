{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  python-dateutil,
  python-slugify,
  requests,
  setuptools,
  sortedcontainers,
}:

buildPythonPackage (finalAttrs: {
  pname = "blinkpy";
  version = "0.25.7";

  src = fetchFromGitHub {
    owner = "fronzbot";
    repo = "blinkpy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/GaSnovF6IwIKdbQ4bTqXI/lZERa2DhbLalOO+ZYXEY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "wheel>=0.40,<0.48" wheel \
      --replace-fail "setuptools>=68,<83" setuptools
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    aiohttp
    python-dateutil
    python-slugify
    requests
    sortedcontainers
  ];

  pyproject = true;

  pythonImportsCheck = [
    "blinkpy"
    "blinkpy.api"
    "blinkpy.auth"
    "blinkpy.blinkpy"
    "blinkpy.camera"
    "blinkpy.helpers.util"
    "blinkpy.sync_module"
  ];

  pythonRelaxDeps = [
    "aiohttp"
    "requests"
  ];

  meta = {
    description = "Python library for the Blink Camera system";
    homepage = "https://github.com/fronzbot/blinkpy";
    changelog = "https://github.com/fronzbot/blinkpy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
