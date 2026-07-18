{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  setuptools-scm,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "crccheck";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "MartinScharrer";
    repo = "crccheck";
    tag = "v${version}";
    hash = "sha256-hT+8+moni7turn5MK719b4Xy336htyWWmoMnhgxKkYo=";
  };

  nativeCheckInputs = [ unittestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "crccheck" ];

  meta = {
    description = "Python library for CRCs and checksums";
    homepage = "https://github.com/MartinScharrer/crccheck";
    changelog = "https://github.com/MartinScharrer/crccheck/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
