{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jsonschema,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "robotframework";
  version = "7.4.2";

  src = fetchFromGitHub {
    owner = "robotframework";
    repo = "robotframework";
    tag = "v${version}";
    hash = "sha256-SSjVrbe3uBqCMEUYjrk2lxHpxzdU6QK2xvEFszhT6lc=";
  };

  nativeCheckInputs = [ jsonschema ];

  checkPhase = ''
    ${python.interpreter} utest/run.py
  '';

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Generic test automation framework";
    homepage = "https://robotframework.org/";
    changelog = "https://github.com/robotframework/robotframework/blob/master/doc/releasenotes/rf-${version}.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bjornfor ];
  };
}
