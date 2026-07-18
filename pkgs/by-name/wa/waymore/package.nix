{
  lib,
  fetchFromGitHub,
  python3Packages,
  testers,
  waymore,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "waymore";
  version = "8.9";

  src = fetchFromGitHub {
    owner = "xnl-h4ck3r";
    repo = "waymore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-niV9aqBlSz9bkMF9uI34bmlm7Mqg3cDZGjjrtGN01Xk=";
  };

  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    requests
    termcolor
    pyyaml
    psutil
    uritools
    tldextract
  ];

  pyproject = true;
  pythonImportsCheck = [ "waymore.waymore" ];

  pythonRemoveDeps = [
    # python already provides urllib.parse
    "urlparse3"
  ];

  passthru.tests.version = testers.testVersion {
    version = "Waymore - v${finalAttrs.version}";
    command = "waymore --version";
    package = waymore;
  };

  meta = {
    description = "Find way more from the Wayback Machine";
    homepage = "https://github.com/xnl-h4ck3r/waymore";
    changelog = "https://github.com/xnl-h4ck3r/waymore/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ genga898 ];
    mainProgram = "waymore";
  };
})
