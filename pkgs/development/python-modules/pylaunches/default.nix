{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pylaunches";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "ludeeus";
    repo = "pylaunches";
    tag = version;
    hash = "sha256-NewzzZuiXwaWU59bu+M2QcSfydL1khvw/YJkbZ58W2Q=";
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

  build-system = [ poetry-core ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pylaunches" ];

  meta = {
    description = "Python module to get information about upcoming space launches";
    homepage = "https://github.com/ludeeus/pylaunches";
    changelog = "https://github.com/ludeeus/pylaunches/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
