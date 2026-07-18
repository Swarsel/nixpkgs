{
  lib,
  buildPythonPackage,
  docopt,
  fetchPypi,
  pytestCheckHook,
  pytz,
  setuptools,
  setuptools-scm,
  sqlalchemy,
}:

buildPythonPackage (finalAttrs: {
  pname = "pygtfs";
  version = "0.1.11";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-NaSGjzBBFK3mqHibcKV2gQIQoWn+qZay7KJasjcwxW4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    docopt
    pytz
    sqlalchemy
  ];

  enabledTestPaths = [ "pygtfs/test/test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "pygtfs" ];

  meta = {
    description = "Python module for GTFS";
    homepage = "https://github.com/jarondl/pygtfs";
    changelog = "https://github.com/jarondl/pygtfs/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "gtfs2db";
  };
})
