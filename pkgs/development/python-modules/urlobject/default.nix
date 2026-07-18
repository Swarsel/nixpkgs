{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pypaInstallHook,
  setuptoolsBuildHook,
}:

buildPythonPackage rec {
  pname = "urlobject";
  version = "2.4.3";

  src = fetchFromGitHub {
    owner = "zacharyvoase";
    repo = "urlobject";
    tag = "v${version}";
    hash = "sha256-4UuQZTkVre8jXlchW7/TjeaADYvLnGMpGbJR/sdeKv4=";
  };

  nativeBuildInputs = [
    pypaInstallHook
    setuptoolsBuildHook
  ];

  # Tests use `nose`
  doInstallCheck = false;
  pyproject = false;
  pythonImportsCheck = [ "urlobject" ];

  meta = {
    description = "Python library for manipulating URLs (and some URIs) in a more natural way";
    homepage = "http://zacharyvoase.github.com/urlobject";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ getchoo ];
  };
}
