{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
}:
let
  pname = "eventkit";
  version = "1.0.3";
  hash = "sha256-mUl/bzxjilD/dhby+M2Iexi7/zdl3BvYaBVU2xRnyTM=";
in
buildPythonPackage {
  inherit pname version;
  src = fetchPypi { inherit pname version hash; };
  propagatedBuildInputs = [ numpy ];
  format = "setuptools";

  meta = {
    description = "Event-driven data pipelines";
    homepage = "https://github.com/erdewit/eventkit";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ cab404 ];
  };
}
