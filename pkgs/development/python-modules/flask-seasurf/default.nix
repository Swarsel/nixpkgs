{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-seasurf";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "maxcountryman";
    repo = "flask-seasurf";
    tag = version;
    hash = "sha256-ajQiDizNaF0em9CVeaHEuJEeSaYraJh9YgvhvBPTIsk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mock
  ];

  build-system = [ setuptools ];
  dependencies = [ flask ];
  pyproject = true;
  pythonImportsCheck = [ "flask_seasurf" ];

  meta = {
    description = "Flask extension for preventing cross-site request forgery";
    homepage = "https://github.com/maxcountryman/flask-seasurf";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ zhaofengli ];
  };
}
