{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "zope-cachedescriptors";
  version = "6.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.cachedescriptors";
    tag = version;
    hash = "sha256-PlezUzuO4P/BOVT6Ll8dYIKssC/glmVd8SCM0afgNC0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ setuptools ];
  enabledTestPaths = [ "src/zope/cachedescriptors/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "zope.cachedescriptors" ];
  pythonNamespaces = [ "zope" ];

  meta = {
    description = "Method and property caching decorators";
    homepage = "https://github.com/zopefoundation/zope.cachedescriptors";
    changelog = "https://github.com/zopefoundation/zope.cachedescriptors/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
