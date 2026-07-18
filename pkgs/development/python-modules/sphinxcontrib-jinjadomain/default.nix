{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-jinjadomain";
  version = "0.5.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-frzcrUnJna8wmKbsC7wduazLSZ8lzOKOCf75Smk675E=";
  };

  build-system = [ setuptools ];
  dependencies = [ sphinx ];

  prePatch = ''
    substituteInPlace sphinxcontrib/jinjadomain.py \
      --replace-fail "content.sort(key=lambda (k, v): k)" "content.sort(key=lambda kv: kv[0])"
  '';

  pyproject = true;
  pythonImportsCheck = [ "sphinxcontrib.jinjadomain" ];

  meta = {
    description = "Sphinx domain for describing jinja templates";
    homepage = "https://github.com/offlinehacker/sphinxcontrib.jinjadomain";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ tochiaha ];
    mainProgram = "sphinxcontrib-jinjadomain";
  };
}
