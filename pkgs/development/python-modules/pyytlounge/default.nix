{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pytest,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyytlounge";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "FabioGNR";
    repo = "pyytlounge";
    tag = "v${version}";
    hash = "sha256-8cdahP1u8Rf4m/167ie9aKcELLiWNvZOx7tV9YLK4nU=";
  };

  nativeCheckInputs = [
    pytest
    pytestCheckHook
    pytest-mock
    pytest-asyncio
  ];

  build-system = [ hatchling ];
  dependencies = [ aiohttp ];
  pyproject = true;

  meta = {
    description = "Python YouTube Lounge API";
    homepage = "https://github.com/FabioGNR/pyytlounge";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.lukegb ];
  };
}
