{
  lib,
  fetchFromGitHub,
  aiosqlite,
  beautifulsoup4,
  buildPythonPackage,
  fake-useragent,
  hatchling,
  httpx,
  loguru,
  pyotp,
  pytest-asyncio,
  pytest-httpx,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "twscrape";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "vladkens";
    repo = "twscrape";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FQYBC/b2L+c6UtqMZcsuVom01n0sRpBvMTnE2zZh86U=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-httpx
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiosqlite
    beautifulsoup4
    fake-useragent
    httpx
    loguru
    pyotp
  ];

  pyproject = true;
  pythonImportsCheck = [ "twscrape" ];
  pythonRelaxDeps = [ "beautifulsoup4" ];

  meta = {
    description = "Twitter API scrapper with authorization support";
    homepage = "https://github.com/vladkens/twscrape";
    changelog = "https://github.com/vladkens/twscrape/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.amadejkastelic ];
  };
})
