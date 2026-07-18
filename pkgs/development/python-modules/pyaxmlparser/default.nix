{
  lib,
  fetchFromGitHub,
  asn1crypto,
  buildPythonPackage,
  click,
  lxml,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyaxmlparser";
  version = "0.3.31";

  src = fetchFromGitHub {
    owner = "appknox";
    repo = "pyaxmlparser";
    rev = "v${version}";
    hash = "sha256-ZV2PyWQfK9xidzGUz7XPAReaVjlB8tMUKQiXoGcFCGs=";
  };

  propagatedBuildInputs = [
    asn1crypto
    click
    lxml
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";

  meta = {
    description = "Python3 Parser for Android XML file and get Application Name without using Androguard";
    homepage = "https://github.com/appknox/pyaxmlparser";

    # Files from Androguard are licensed ASL 2.0
    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = [ ];
    mainProgram = "apkinfo";
  };
}
