{
  lib,
  buildPythonPackage,
  fetchPypi,
  pillow,
  pycryptodome,
  reportlab,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pdfrw2";
  version = "0.5.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5qnMq4Pnaaeov+Lb3fD0ndfr5SAy6SlXTwG7v6IZce0=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    pillow
    reportlab
    pycryptodome
  ];

  pyproject = true;
  pythonImportsCheck = [ "pdfrw" ];

  meta = {
    description = "Pure Python library that reads and writes PDFs";
    homepage = "https://github.com/sarnold/pdfrw";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ loicreynier ];
  };
}
