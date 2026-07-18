{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  flask,
  pyjwt,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "flask-jwt-extended";
  version = "4.7.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-eP0PRgMX+s86AISmRX/68vHdqe771Xb5TOo1sOrdVTE=";
    pname = "flask_jwt_extended";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    flask
    pyjwt
    python-dateutil
    werkzeug
  ];

  optional-dependencies.asymmetric_crypto = [ cryptography ];
  pyproject = true;
  pythonImportsCheck = [ "flask_jwt_extended" ];

  meta = {
    description = "JWT extension for Flask";
    homepage = "https://flask-jwt-extended.readthedocs.io/";
    changelog = "https://github.com/vimalloc/flask-jwt-extended/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gerschtli ];
  };
}
