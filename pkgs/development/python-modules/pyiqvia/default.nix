{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  backoff,
  buildPythonPackage,
  certifi,
  poetry-core,
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "pyiqvia";
  version = "2023.12.0";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "pyiqvia";
    tag = version;
    hash = "sha256-qq6UQUz60WkmWqdmExlSQT3wapaHJr8DeH1eVrTOnpQ=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    aiohttp
    backoff
    certifi
    yarl
  ];

  nativeCheckInputs = [
    aresponses
    pytest-aiohttp
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  disabledTestPaths = [
    # Ignore the examples as they are prefixed with test_
    "examples/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyiqvia" ];

  meta = {
    description = "Module for working with IQVIA data";

    longDescription = ''
      pyiqvia is an async-focused Python library for allergen, asthma, and
      disease data from the IQVIA family of websites (such as https://pollen.com,
      https://flustar.com and more).
    '';

    homepage = "https://github.com/bachya/pyiqvia";
    changelog = "https://github.com/bachya/pyiqvia/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
