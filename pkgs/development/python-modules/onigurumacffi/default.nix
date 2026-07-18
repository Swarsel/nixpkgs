{
  lib,
  buildPythonPackage,
  cffi,
  fetchPypi,
  oniguruma,
  setuptools,
}:
buildPythonPackage rec {
  pname = "onigurumacffi";
  version = "1.5.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-1Pqb7kSm04qYsiN8Z9ms3yftDDLWwhgSX+RmgaXt6k0=";
  };

  buildInputs = [
    oniguruma
    setuptools
    cffi
  ];

  pyproject = true;

  meta = {
    description = "Python cffi bindings for the oniguruma regex engine";
    homepage = "https://github.com/asottile/onigurumacffi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ melkor333 ];
  };
}
