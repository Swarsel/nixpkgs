{
  lib,
  fetchFromGitLab,
  babel,
  buildPythonPackage,
  html2text,
  lxml,
  packaging,
  pillow,
  prettytable,
  pycountry,
  pytestCheckHook,
  python-dateutil,
  python-jose,
  pyyaml,
  requests,
  responses,
  rich,
  setuptools,
  termcolor,
  testers,
  unidecode,
  woob,
}:

buildPythonPackage rec {
  pname = "woob";
  version = "3.7";

  src = fetchFromGitLab {
    owner = "woob";
    repo = "woob";
    tag = version;
    hash = "sha256-EZHzw+/BIIvmDXG4fF367wsdUTVTHWYb0d0U56ZXwOs=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  build-system = [ setuptools ];

  dependencies = [
    babel
    python-dateutil
    python-jose
    html2text
    lxml
    packaging
    pillow
    prettytable
    pycountry
    pyyaml
    requests
    rich
    unidecode
    termcolor
  ];

  disabledTests = [
    # require networking
    "test_ciphers"
    "test_verify"
  ];

  pyproject = true;
  pythonImportsCheck = [ "woob" ];

  pythonRelaxDeps = [
    "packaging"
    "rich"
    "requests"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${version}";
    package = woob;
  };

  meta = {
    description = "Collection of applications and APIs to interact with websites";
    homepage = "https://woob.tech";
    changelog = "https://gitlab.com/woob/woob/-/blob/${src.rev}/ChangeLog";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ DamienCassou ];
    mainProgram = "woob";
  };
}
