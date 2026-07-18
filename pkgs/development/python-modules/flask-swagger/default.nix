{
  lib,
  buildPythonPackage,
  fetchPypi,
  flask,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "flask-swagger";
  version = "0.2.14";

  src = fetchPypi {
    inherit pname version;
    sha256 = "b4085f5bc36df4c20b6548cd1413adc9cf35719b0f0695367cd542065145294d";
  };

  propagatedBuildInputs = [
    flask
    pyyaml
  ];

  # No Tests
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Extract swagger specs from your flask project";
    homepage = "https://github.com/gangverk/flask-swagger";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vanschelven ];
    mainProgram = "flaskswagger";
  };
}
