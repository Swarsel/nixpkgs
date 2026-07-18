{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  hypothesis,
  pytestCheckHook,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "datrie";
  version = "0.8.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6gIa1MiovxTginHHhypiKqOZpRD5gSloJQkcfKBDboA=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace '"pytest-runner", ' ""
  '';

  # workaround https://github.com/pytries/datrie/issues/101
  env.CFLAGS = "-Wno-error=incompatible-pointer-types";

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  dependencies = [
    setuptools
    wheel
    cython
  ];

  pyproject = true;
  pythonImportsCheck = [ "datrie" ];

  meta = {
    description = "Super-fast, efficiently stored Trie for Python";
    homepage = "https://github.com/kmike/datrie";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ lewo ];
  };
}
