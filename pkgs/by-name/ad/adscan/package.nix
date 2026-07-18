{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "adscan";
  version = "9.2.1";

  src = fetchFromGitHub {
    owner = "ADScanPro";
    repo = "adscan";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gBlS5co1LUu07Xz+JZWi4zNOPtPHGfl+StpFPauOFG4=";
  };

  # Project has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    aardwolf
    aiosmb
    badldap
    certifi
    credsweeper
    dnspython
    graphviz
    impacket
    jinja2
    kerbad
    markitdown
    netifaces
    packaging
    playwright
    posthog
    prompt-toolkit
    psutil
    pydantic-ai-slim
    pydantic-settings
    pypsrp
    pypykatz
    python-docx
    python-magic
    questionary
    redis
    requests
    rich
    scapy
    selenium
    sentry-sdk
    textual
    weasyprint
    winacl
  ];

  pyproject = true;

  pythonImportsCheck = [
    "adscan_core"
    "adscan_launcher"
  ];

  pythonRelaxDeps = [ "credsweeper" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Active Directory pentesting tool for Linux";
    homepage = "https://github.com/ADScanPro/adscan";
    changelog = "https://github.com/ADScanPro/adscan/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.bsl11;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "adscan";
  };
})
