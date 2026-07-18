{
  lib,
  atpublic,
  buildPythonPackage,
  fetchPypi,
  pdm-pep517,
  pytest-cov-stub,
  pytestCheckHook,
  sybil,
}:

buildPythonPackage rec {
  pname = "flufl-i18n";
  version = "4.1.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-wKz6aggkJ9YBJ+o75XjC4Ddnn+Zi9hlYDnliwTc7DNs=";
    pname = "flufl.i18n";
  };

  nativeBuildInputs = [ pdm-pep517 ];
  propagatedBuildInputs = [ atpublic ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    sybil
  ];

  pyproject = true;
  pythonImportsCheck = [ "flufl.i18n" ];
  pythonNamespaces = [ "flufl" ];

  meta = {
    description = "High level API for internationalizing Python libraries and applications";
    homepage = "https://gitlab.com/warsaw/flufl.i18n";
    changelog = "https://gitlab.com/warsaw/flufl.i18n/-/raw/${version}/docs/NEWS.rst";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
