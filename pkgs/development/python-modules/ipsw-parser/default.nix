{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cached-property,
  click,
  coloredlogs,
  construct,
  plumbum,
  pyimg4,
  remotezip2,
  requests,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "ipsw-parser";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "doronz88";
    repo = "ipsw_parser";
    tag = "v${version}";
    hash = "sha256-+lhrRlIuchWIezzxkpTv4gdxXbOpNPWOJrdOU/g1i68=";
  };

  checkPhase = ''
    runHook preCheck

    "$out"/bin/${meta.mainProgram} --help

    runHook postCheck
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cached-property
    click
    coloredlogs
    construct
    plumbum
    pyimg4
    remotezip2
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "ipsw_parser" ];

  meta = {
    description = "Python3 utility for parsing and extracting data from IPSW";
    homepage = "https://github.com/doronz88/ipsw_parser";
    changelog = "https://github.com/doronz88/ipsw_parser/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.dotlambda ];
    mainProgram = "ipsw-parser";
  };
}
