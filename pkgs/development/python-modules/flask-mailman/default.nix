{
  lib,
  fetchFromGitHub,
  aiosmtpd,
  buildPythonPackage,
  flask,
  mkdocs-material-extensions,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "flask-mailman";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "waynerv";
    repo = "flask-mailman";
    tag = "v${version}";
    hash = "sha256-0kD3rxFDJ7FcmBLVju75z1nf6U/7XfjiLD/oM/VP4jQ=";
  };

  nativeCheckInputs = [
    aiosmtpd
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    flask
    mkdocs-material-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_mailman" ];

  meta = {
    description = "Flask extension providing simple email sending capabilities";
    homepage = "https://github.com/waynerv/flask-mailman";
    changelog = "https://github.com/waynerv/flask-mailman/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ gador ];
  };
}
