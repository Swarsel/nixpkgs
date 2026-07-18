{
  lib,
  buildPythonPackage,
  fetchPypi,
  glibcLocalesUtf8,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-bugzilla";
  version = "3.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-4YIgFx4DPrO6YAxNE5NZ0BqhrOwdrrxDCJEORQdj3kc=";
    pname = "python_bugzilla";
  };

  nativeCheckInputs = [
    pytestCheckHook
    glibcLocalesUtf8
    responses
  ];

  preCheck = ''
    mkdir -p check-phase
    export HOME=$(pwd)/check-phase
  '';

  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;

  meta = {
    description = "Bugzilla XMLRPC access module";
    homepage = "https://github.com/python-bugzilla/python-bugzilla";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ pierron ];
    platforms = lib.platforms.all;
    mainProgram = "bugzilla";
  };
}
