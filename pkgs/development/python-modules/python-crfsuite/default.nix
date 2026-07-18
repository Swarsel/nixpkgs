{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "python-crfsuite";
  version = "0.9.12";

  src = fetchPypi {
    inherit version;
    hash = "sha256-2zf8zDvY8MScKKdpfKecidZ7P9W/EZEihmFpJArExIA=";
    pname = "python_crfsuite";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # make sure import the built version, not the source one
    rm -r pycrfsuite
  '';

  build-system = [
    cython
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pycrfsuite" ];

  meta = {
    description = "Python binding for CRFsuite";
    homepage = "https://github.com/scrapinghub/python-crfsuite";
    changelog = "https://github.com/scrapinghub/python-crfsuite/blob/${version}/CHANGES.rst";
    license = lib.licenses.mit;
    teams = [ lib.teams.tts ];
  };
}
