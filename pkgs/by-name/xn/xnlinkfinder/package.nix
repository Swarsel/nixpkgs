{
  lib,
  fetchFromGitHub,
  python3,
  writableTmpDirAsHomeHook,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "xnlinkfinder";
  version = "8.2";

  src = fetchFromGitHub {
    owner = "xnl-h4ck3r";
    repo = "xnLinkFinder";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xym8ruHPAseqmWLUtCPTlpr3REDrpbWor66aNvfASjA=";
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  # Project has no test
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    beautifulsoup4
    html5lib
    inflect
    lxml
    playwright
    psutil
    pypdf
    pyyaml
    requests
    termcolor
    tldextract
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "xnLinkFinder" ];

  pythonRemoveDeps = [
    # python already provides urllib.parse
    "urlparse3"
  ];

  meta = {
    description = "Tool to discover endpoints, potential parameters, and a target specific wordlist for a given target";
    homepage = "https://github.com/xnl-h4ck3r/xnLinkFinder";
    changelog = "https://github.com/xnl-h4ck3r/xnLinkFinder/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "xnLinkFinder";
  };
})
