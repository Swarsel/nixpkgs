{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  httpx,
  nest-asyncio,
  pydantic,
  python-dotenv,
  requests,
  setuptools,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "firecrawl-py";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "mendableai";
    repo = "firecrawl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7dB3jdp5jkRiNx63C5sjs3t85fuz5vzurfvYY5jWQyU=";
  };

  # No tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    httpx
    nest-asyncio
    pydantic
    python-dotenv
    requests
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "firecrawl" ];
  sourceRoot = "${finalAttrs.src.name}/apps/python-sdk";

  meta = {
    description = "Turn entire websites into LLM-ready markdown or structured data. Scrape, crawl and extract with a single API";
    homepage = "https://firecrawl.dev";
    changelog = "https://github.com/mendableai/firecrawl/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
