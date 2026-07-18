{
  lib,
  fetchFromGitHub,
  aiohttp,
  anyio,
  buildPythonPackage,
  dirty-equals,
  distro,
  hatch-fancy-pypi-readme,
  hatchling,
  httpx,
  httpx-aiohttp,
  nest-asyncio,
  pydantic,
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  respx,
  sniffio,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "groq";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "groq";
    repo = "groq-python";
    tag = "v${version}";
    hash = "sha256-WtibHngPubo4p+xtdvqqDTvRFMk+dSBmxjoQxVPyXQM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "hatchling==1.26.3" \
      "hatchling>=1.26.3"
  '';

  nativeCheckInputs = [
    dirty-equals
    nest-asyncio
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
    respx
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    hatch-fancy-pypi-readme
    hatchling
  ];

  dependencies = [
    anyio
    distro
    httpx
    pydantic
    sniffio
    typing-extensions
  ];

  disabledTests = [
    # Tests require network access
    "test_method"
    "test_streaming"
    "test_raw_response"
    "test_copy_build_request"
  ];

  optional-dependencies = {
    aiohttp = [
      aiohttp
      httpx-aiohttp
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "groq" ];

  meta = {
    description = "Library for the Groq API";
    homepage = "https://github.com/groq/groq-python";
    changelog = "https://github.com/groq/groq-python/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      fab
      sarahec
    ];
  };
}
