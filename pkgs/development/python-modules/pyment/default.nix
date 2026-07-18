{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "pyment";
  version = "0.3.3";

  src = fetchPypi {
    inherit version;
    sha256 = "951a4c52d6791ccec55bc739811169eed69917d3874f5fe722866623a697f39d";
    pname = "Pyment";
  };

  # Tests are not included in PyPI tarball
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Create, update or convert docstrings in existing Python files, managing several styles";
    homepage = "https://github.com/dadadel/pyment";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ jethro ];
    mainProgram = "pyment";
  };
}
