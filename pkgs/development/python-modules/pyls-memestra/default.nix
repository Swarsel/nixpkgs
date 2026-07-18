{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  deprecated,
  memestra,
  python-lsp-server,
}:

buildPythonPackage rec {
  pname = "pyls-memestra";
  version = "0.0.16";

  src = fetchFromGitHub {
    owner = "QuantStack";
    repo = "pyls-memestra";
    tag = version;
    hash = "sha256-C1d2BibjpoZCPSy39PkdcLiLIwZZG+XTDWXVjTT1Bws=";
  };

  # Tests fail because they rely on writing to read-only files
  doCheck = false;

  dependencies = [
    deprecated
    memestra
    python-lsp-server
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyls_memestra" ];

  meta = {
    description = "Memestra plugin for the Python Language Server";
    homepage = "https://github.com/QuantStack/pyls-memestra";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
