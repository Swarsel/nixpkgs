{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pretix-plugin-build,
  setuptools,
}:

buildPythonPackage {
  pname = "pretix-stretchgoals";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "rixx";
    repo = "pretix-stretchgoals";
    rev = "177238920a863f71cf03f174e2841f5b630574e9";
    hash = "sha256-Sbbxg6viRdALjZwqEmN2Js/qbMShe5xMg00jUccnhsA=";
  };

  doCheck = false; # no tests

  build-system = [
    pretix-plugin-build
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pretix_stretchgoals"
  ];

  meta = {
    description = "Display the average ticket sales price over time";
    homepage = "https://github.com/rixx/pretix-stretchgoals";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
