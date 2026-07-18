{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  freezegun,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "aiorecollect";
  version = "2023.12.0";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "aiorecollect";
    tag = version;
    hash = "sha256-Rj0+r7eERLY5VzmuDQH/TeVLfmvmKwPqcvd1b/To0Ts=";
  };

  postPatch = ''
    # this is not used directly by the project
    sed -i '/certifi =/d' pyproject.toml
  '';

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ aiohttp ];

  nativeCheckInputs = [
    aresponses
    freezegun
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  disabledTestPaths = [
    # Ignore the examples directory as the files are prefixed with test_.
    "examples/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiorecollect" ];

  meta = {
    description = "Python library for the Recollect Waste API";

    longDescription = ''
      aiorecollect is a Python asyncio-based library for the ReCollect
      Waste API. It allows users to programmatically retrieve schedules
      for waste removal in their area, including trash, recycling, compost
      and more.
    '';

    homepage = "https://github.com/bachya/aiorecollect";
    changelog = "https://github.com/bachya/aiorecollect/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
