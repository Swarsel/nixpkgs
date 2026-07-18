{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dissect-cstruct,
  dissect-util,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dissect-cim";
  version = "3.13";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.cim";
    tag = version;
    hash = "sha256-S3EbGWLajfWTy0h0cmECHmHH/QLu5WmhnqTCQWSbYs8=";
  };

  # gzip.BadGzipFile: Not a gzipped file
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dissect-cstruct
    dissect-util
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.cim" ];

  meta = {
    description = "Dissect module implementing a parser for the Windows Common Information Model (CIM) database";
    homepage = "https://github.com/fox-it/dissect.cim";
    changelog = "https://github.com/fox-it/dissect.cim/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
