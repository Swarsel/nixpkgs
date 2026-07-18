{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jsonformatter";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "MyColorfulDays";
    repo = "jsonformatter";
    tag = "v${version}";
    hash = "sha256-A+lsSBrm/64w7yMabmuAbRCLwUUdulGH3jB/DbYJ2QY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "jsonformatter" ];

  meta = {
    description = "Formatter to output JSON log, e.g. output LogStash needed log";
    homepage = "https://github.com/MyColorfulDays/jsonformatter";
    changelog = "https://github.com/MyColorfulDays/jsonformatter/releases/tag/v${version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ gador ];
  };
}
