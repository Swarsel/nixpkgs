{
  lib,
  buildPythonPackage,
  fetchPypi,
  openpyxl,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-excel-table";
  version = "1.0.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256:1q79byn3k3ribvwqafbpixwabjhymk46ns8ym0hxcn8vhf5nljzd";
  };

  propagatedBuildInputs = [
    sphinx
    openpyxl
  ];

  # No tests present upstream
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "sphinxcontrib.excel_table" ];
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx excel-table extension";
    homepage = "https://github.com/hackerain/sphinxcontrib-excel-table";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ raboof ];
  };
}
