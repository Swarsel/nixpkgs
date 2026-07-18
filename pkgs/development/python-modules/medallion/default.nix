{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  flask-httpauth,
  pymongo,
  pytestCheckHook,
  pytz,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "medallion";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "oasis-open";
    repo = "cti-taxii-server";
    tag = "v${version}";
    hash = "sha256-+fWifWi/XR6MSOLhWXn2CFpItVdkOpzQItlrZkjapAk=";
  };

  build-system = [ setuptools ];

  dependencies = [
    flask
    flask-httpauth
    pymongo
    pytz
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "medallion" ];

  meta = {
    description = "Minimal implementation of a TAXII 2.1 Server in Python";
    homepage = "https://medallion.readthedocs.io/en/latest/";
    changelog = "https://github.com/oasis-open/cti-taxii-server/blob/v${version}/CHANGES.txt";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ PapayaJackal ];
  };
}
