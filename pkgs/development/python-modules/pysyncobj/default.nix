{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pysyncobj";
  version = "0.3.15";

  src = fetchFromGitHub {
    owner = "bakwc";
    repo = "PySyncObj";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6kvWcKSyVtK3sdeetJxx1golIXRY/RYkFCpWBfs10rg=";
  };

  # Tests require network features
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pysyncobj" ];

  meta = {
    description = "Python library for replicating your class";
    homepage = "https://github.com/bakwc/PySyncObj";
    changelog = "https://github.com/bakwc/PySyncObj/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "syncobj_admin";
  };
})
