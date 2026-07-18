{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  mysqlclient,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-mysqldb";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "alexferl";
    repo = "flask-mysqldb";
    rev = "v${version}";
    hash = "sha256-RHAB9WGRzojH6eAOG61QguwF+4LssO9EcFjbWxoOtF4=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    flask
    mysqlclient
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "flask_mysqldb" ];

  meta = {
    description = "MySQL connection support for Flask";
    homepage = "https://github.com/alexferl/flask-mysqldb";
    changelog = "https://github.com/alexferl/flask-mysqldb/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ netali ];
  };
}
