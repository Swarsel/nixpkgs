{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  beautifulsoup4,
  buildPythonPackage,
  html5lib,
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
  pythonAtLeast,
  requests,
  requests-mock,
  setuptools,
  setuptools-scm,
  urllib3,
}:

buildPythonPackage rec {
  pname = "raincloudy";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "vanstinator";
    repo = "raincloudy";
    tag = version;
    hash = "sha256-qCkBVirM09iA1sXiOB9FJns8bHjQq7rRk8XbRWrtBDI=";
  };

  postPatch = ''
    # https://github.com/vanstinator/raincloudy/pull/60
    substituteInPlace setup.py \
      --replace-fail "bs4" "beautifulsoup4" \

    # fix raincloudy.aio package discovery, by relying on
    # autodiscovery instead.
    sed -i '/packages=/d' setup.py
  '';

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-aiohttp
    pytestCheckHook
    requests-mock
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiohttp
    requests
    beautifulsoup4
    urllib3
    html5lib
  ];

  # https://github.com/vanstinator/raincloudy/issues/65
  disabled = pythonAtLeast "3.12";

  disabledTests = [
    # Test requires network access
    "test_attributes"
  ];

  format = "setuptools";
  pypriject = true;

  pythonImportsCheck = [
    "raincloudy"
    "raincloudy.aio"
  ];

  meta = {
    description = "Module to interact with Melnor RainCloud Smart Garden Watering Irrigation Timer";
    homepage = "https://github.com/vanstinator/raincloudy";
    changelog = "https://github.com/vanstinator/raincloudy/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
