{
  lib,
  fetchFromGitLab,
  attrs,
  beautifulsoup4,
  buildPythonPackage,
  certvalidator,
  colorama,
  cryptoparser,
  dnspython,
  pathlib2,
  pyfakefs,
  python-dateutil,
  requests,
  setuptools,
  setuptools-scm,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "cryptolyzer";
  version = "1.2.1";

  src = fetchFromGitLab {
    owner = "coroner";
    repo = "cryptolyzer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-v+himg/DOBlIRiWBIGkxiahT3JGp384Ed4cUCIq6TOw=";
  };

  patches = [
    # https://gitlab.com/coroner/cryptolyzer/-/merge_requests/4
    ./fix-dirs-exclude.patch
  ];

  # Tests require networking
  doCheck = false;

  postInstall = ''
    find $out -name "__pycache__" -type d | xargs rm -rv

    # Prevent creating more binary byte code later (e.g. during
    # pythonImportsCheck)
    export PYTHONDONTWRITEBYTECODE=1
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    attrs
    beautifulsoup4
    certvalidator
    colorama
    cryptoparser
    dnspython
    pathlib2
    pyfakefs
    python-dateutil
    requests
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "cryptolyzer" ];
  pythonRemoveDeps = [ "bs4" ];

  meta = {
    description = "Cryptographic protocol analyzer";
    homepage = "https://gitlab.com/coroner/cryptolyzer";
    changelog = "https://gitlab.com/coroner/cryptolyzer/-/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    mainProgram = "cryptolyze";
    teams = with lib.teams; [ ngi ];
  };
})
