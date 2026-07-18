{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPythonPackage,
  icu,
  pkg-config,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "pyicu";
  version = "2.15.3";

  src = fetchFromGitLab {
    owner = "main";
    repo = "pyicu";
    tag = "v${version}";
    hash = "sha256-vbrl6n7X85sQIdgj+Z0Xr6x/L8roK5Z/mNj53zyWQGs=";
    domain = "gitlab.pyicu.org";
  };

  postPatch = ''
    substituteInPlace setup.py --replace-fail "'pkg-config'" "'${stdenv.cc.targetPrefix}pkg-config'"
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ icu ];

  nativeCheckInputs = [
    pytestCheckHook
    six
  ];

  build-system = [ setuptools ];

  disabledTestPaths = [
    # AssertionError: '$' != 'US Dollar'
    "test/test_NumberFormatter.py::TestCurrencyUnit::testGetName"
    # AssertionError: Lists differ: ['a', 'b', 'c', 'd'] != ['a', 'b', 'c', 'd', ...
    "test/test_UnicodeSet.py::TestUnicodeSet::testIterators"
  ];

  pyproject = true;
  pythonImportsCheck = [ "icu" ];

  meta = {
    description = "Python extension wrapping the ICU C++ API";
    homepage = "https://gitlab.pyicu.org/main/pyicu";
    changelog = "https://gitlab.pyicu.org/main/pyicu/-/raw/v${version}/CHANGES";
    license = lib.licenses.mit;
  };
}
