{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "types-pillow";
  version = "10.2.0.20240822";

  src = fetchPypi {
    inherit version;
    hash = "sha256-VZ+1Ki75kcMm5KDSCsyzu2Onuo1A60k+DssDELpS8NM=";
    pname = "types-Pillow";
  };

  # Modules doesn't have tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "PIL-stubs" ];

  meta = {
    description = "Typing stubs for Pillow";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ arjan-s ];
  };
}
