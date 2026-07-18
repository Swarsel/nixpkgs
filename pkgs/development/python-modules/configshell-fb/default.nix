{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pyparsing,
}:

buildPythonPackage rec {
  pname = "configshell-fb";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "open-iscsi";
    repo = "configshell-fb";
    tag = "v${version}";
    hash = "sha256-q/Tx/9BBnxW6busbrigeesxNa5NvBgfKYDNeDquDTOc=";
  };

  # Module has no tests
  doCheck = false;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    pyparsing
  ];

  pyproject = true;
  pythonImportsCheck = [ "configshell" ];

  meta = {
    description = "Python library for building configuration shells";
    homepage = "https://github.com/open-iscsi/configshell-fb";
    changelog = "https://github.com/open-iscsi/configshell-fb/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
