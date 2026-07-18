{
  lib,
  fetchFromGitHub,
  authres,
  buildPythonPackage,
  dkimpy,
  dnspython,
  publicsuffix2,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "authheaders";
  version = "0.16.3";

  src = fetchFromGitHub {
    owner = "ValiMail";
    repo = "authentication-headers";
    tag = version;
    hash = "sha256-BFMZpSJ4qCEL42xTiM/D5dkatxohiCrOWAkNZHFUhac=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    authres
    dnspython
    dkimpy
    publicsuffix2
    setuptools
  ];

  disabledTests = [
    # Test fails with timeout even if the resolv.conf hack is present
    "test_authenticate_dmarc_psdsub"
  ];

  pyproject = true;
  pythonImportsCheck = [ "authheaders" ];

  meta = {
    description = "Python library for the generation of email authentication headers";
    homepage = "https://github.com/ValiMail/authentication-headers";
    changelog = "https://github.com/ValiMail/authentication-headers/blob${version}/CHANGES";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "dmarc-policy-find";
  };
}
