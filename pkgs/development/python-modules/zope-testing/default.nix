{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isPyPy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "zope-testing";
  version = "6.1";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.testing";
    tag = version;
    hash = "sha256-dAUiG8DxlhQKMBXh49P0CDC9UjqAYjB+2vVCTI36cgc=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools >= 78.1.1,< 81" setuptools
  '';

  doCheck = !isPyPy;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "src/zope/testing/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "zope.testing" ];
  pythonNamespaces = [ "zope" ];

  meta = {
    description = "Zope testing helpers";
    homepage = "https://github.com/zopefoundation/zope.testing";
    changelog = "https://github.com/zopefoundation/zope.testing/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
