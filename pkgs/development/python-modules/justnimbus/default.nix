{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  requests,
}:

buildPythonPackage rec {
  pname = "justnimbus";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "kvanzuijlen";
    repo = "justnimbus";
    tag = version;
    hash = "sha256-FsuvpmMWBYI1LheO3NFfCeaW4m3YQ41Tc81TP3gdNqo=";
  };

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ requests ];
  # Module has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "justnimbus" ];

  meta = {
    description = "Library for the JustNimbus API";
    homepage = "https://github.com/kvanzuijlen/justnimbus";
    changelog = "https://github.com/kvanzuijlen/justnimbus/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
