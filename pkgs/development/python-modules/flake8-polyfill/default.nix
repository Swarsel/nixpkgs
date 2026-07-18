{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  flake8,
  mock,
  pep8,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flake8-polyfill";
  version = "1.0.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1nlf1mkqw856vi6782qcglqhaacb23khk9wkcgn55npnjxshhjz4";
  };

  patches = [
    # Skip unnecessary tests on Flake8, https://github.com/PyCQA/pep8-naming/pull/181
    (fetchpatch {
      name = "skip-tests.patch";
      sha256 = "mElZafodq8dF3wLO/LOqwFb7eLMsPLlEjNSu5AWqets=";
      url = "https://github.com/PyCQA/flake8-polyfill/commit/3cf414350e82ceb835ca2edbd5d5967d33e9ff35.patch";
    })
  ];

  postPatch = ''
    # Failed: [pytest] section in setup.cfg files is no longer supported, change to [tool:pytest] instead.
    substituteInPlace setup.cfg \
      --replace-fail pytest 'tool:pytest'
  '';

  nativeCheckInputs = [
    mock
    pep8
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ flake8 ];
  pyproject = true;
  pythonImportsCheck = [ "flake8_polyfill" ];

  meta = {
    description = "Polyfill package for Flake8 plugins";
    homepage = "https://gitlab.com/pycqa/flake8-polyfill";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eadwu ];
  };
}
