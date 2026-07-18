{
  lib,
  fetchFromGitHub,
  # tests
  asgiref,
  blinker,
  buildPythonPackage,
  # dependencies
  flask,
  # build-system
  flit-core,
  pytestCheckHook,
  semantic-version,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "flask-login";
  version = "0.7.0dev0-2024-06-18";

  src = fetchFromGitHub {
    owner = "maxcountryman";
    repo = "flask-login";
    rev = "30675c56b651389d47b47eeb1ad114decb35b8fc";
    hash = "sha256-mIEYZnYWerjCetQuV2HRcmerMh2uLWNvHV7tfo5j4PU=";
  };

  nativeCheckInputs = [
    asgiref
    blinker
    pytestCheckHook
    semantic-version
  ];

  build-system = [ flit-core ];

  dependencies = [
    flask
    werkzeug
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_login" ];

  meta = {
    description = "User session management for Flask";
    homepage = "https://github.com/maxcountryman/flask-login";
    changelog = "https://github.com/maxcountryman/flask-login/blob/${version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
