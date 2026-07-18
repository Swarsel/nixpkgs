{
  lib,
  blessed,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "dashing";
  version = "0.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JRRgjg8pp3Xb0bERFWEhnOg9U8+kuqL+QQH6uE/Vbxs=";
  };

  propagatedBuildInputs = [ blessed ];
  format = "setuptools";

  meta = {
    description = "Terminal dashboards for Python";
    homepage = "https://github.com/FedericoCeratto/dashing";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ juliusrickert ];
  };
}
