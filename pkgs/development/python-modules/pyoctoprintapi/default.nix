{
  lib,
  fetchFromGitHub,
  # propagated
  aiohttp,
  buildPythonPackage,
  # tests
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

let
  pname = "pyoctoprintapi";
  version = "0.1.14";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "rfleming71";
    repo = "pyoctoprintapi";
    tag = "v${version}";
    hash = "sha256-DKqkT0Wyxf4grXBqei9IYBGMOgPxjzuo955M/nHDLo8=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ aiohttp ];

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyoctoprintapi" ];

  meta = {
    description = "Simple async wrapper around the Octoprint API";
    homepage = "https://github.com/rfleming71/pyoctoprintapi";
    changelog = "https://github.com/rfleming71/pyoctoprintapi/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
