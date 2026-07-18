{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
  ply,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "djangoql";
  version = "0.19.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-vOCdUoV4V7InRPkyQfFtXGKhsRing04civoUvruWTu4=";
  };

  nativeCheckInputs = [ django ];

  checkPhase = ''
    export PYTHONPATH=test_project:$PYTHONPATH
    ${python.executable} test_project/manage.py test core.tests
  '';

  build-system = [ setuptools ];
  dependencies = [ ply ];
  pyproject = true;
  pythonImportsCheck = [ "djangoql" ];

  meta = {
    description = "Advanced search language for Django";
    homepage = "https://github.com/ivelum/djangoql";
    changelog = "https://github.com/ivelum/djangoql/blob/master/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erikarvstedt ];
  };
})
