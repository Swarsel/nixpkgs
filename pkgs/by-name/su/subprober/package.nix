{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "subprober";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "RevoltSecurities";
    repo = "SubProber";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CxmePd1dw9H/XLQZ16JMF1pdFFOI59Qa2knTnKKzFvM=";
  };

  # Project has no tests
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    aiodns
    aiofiles
    aiohttp
    alive-progress
    anyio
    appdirs
    arsenic
    beautifulsoup4
    colorama
    fake-useragent
    httpx
    requests
    rich
    structlog
    urllib3
    uvloop
  ];

  pyproject = true;
  pythonImportsCheck = [ "subprober" ];

  meta = {
    description = "Subdomain scanning tool";
    homepage = "https://github.com/RevoltSecurities/SubProber";
    changelog = "https://github.com/RevoltSecurities/SubProber/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "subprober";
  };
})
