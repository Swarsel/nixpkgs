{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  zope-testing,
}:

buildPythonPackage rec {
  pname = "zc-lockfile";
  version = "4.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zc.lockfile";
    tag = version;
    hash = "sha256-74FE2KEf4RpE8Kum1zW3M7f5/pZujaZFGo6TJjqfMyw=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  nativeCheckInputs = [
    pytestCheckHook
    zope-testing
  ];

  build-system = [ setuptools ];
  enabledTestPaths = [ "src/zc/lockfile/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "zc.lockfile" ];
  pythonNamespaces = [ "zc" ];

  meta = {
    description = "Inter-process locks";
    homepage = "https://github.com/zopefoundation/zc.lockfile";
    changelog = "https://github.com/zopefoundation/zc.lockfile/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
