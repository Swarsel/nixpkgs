{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "whoosh";
  version = "2.7.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-fKVjPb+p4OD6QA0xUaigxL7FO9Ls7cCmdwWxdWXDGoM=";
    pname = "Whoosh";
  };

  # Wrong encoding
  postPatch = ''
    rm tests/test_reading.py
    substituteInPlace setup.cfg \
      --replace-fail "[pytest]" "[tool:pytest]"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  disabledTests = [ "test_minimize_dfa" ];
  pyproject = true;
  pythonImportsCheck = [ "whoosh" ];

  meta = {
    description = "Fast, pure-Python full text indexing, search, and spell checking library";
    homepage = "https://github.com/mchaput/whoosh";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
