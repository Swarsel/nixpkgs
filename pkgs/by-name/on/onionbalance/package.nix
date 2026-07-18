{
  lib,
  fetchFromGitLab,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "onionbalance";
  version = "0.2.4";

  src = fetchFromGitLab {
    owner = "tpo";
    repo = "onion-services/onionbalance";
    tag = finalAttrs.version;
    hash = "sha256-amwKP9LJ7aHPECNUNTluFpgIFSRLxR7eHQxBxW5574I=";
    domain = "gitlab.torproject.org";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    cryptography
    pycryptodomex
    pyyaml
    setproctitle
    stem
  ];

  pyproject = true;

  meta = {
    description = "Tool for loadbalancing onion services";
    homepage = "https://github.com/torproject/onionbalance";
    changelog = "https://github.com/torproject/onionbalance/blob/${finalAttrs.version}/docs/changelog.md";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.ForgottenBeast ];
    mainProgram = "onionbalance";
  };
})
