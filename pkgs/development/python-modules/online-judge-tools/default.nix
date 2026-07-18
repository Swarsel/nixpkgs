{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  online-judge-api-client,
  packaging,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "online-judge-tools";
  version = "12.0.0";

  src = fetchFromGitHub {
    owner = "online-judge-tools";
    repo = "oj";
    tag = "v${version}";
    hash = "sha256-m6V4Sq3yU/KPnbpA0oCLI/qaSrAPA6TutcBL5Crb/Cc=";
  };

  # Requires internet access
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    colorama
    online-judge-api-client
    packaging
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "onlinejudge"
    "onlinejudge_command"
  ];

  meta = {
    description = "Tools for various online judges. Download sample cases, generate additional test cases, test your code, and submit it";
    homepage = "https://github.com/online-judge-tools/oj";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sei40kr ];
    mainProgram = "oj";
  };
}
