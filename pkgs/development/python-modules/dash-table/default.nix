{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "dash-table";
  version = "5.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-GGJNaT1MjvLd7Jmm8WdZNDen6gvxU6og8xjBcMW8cwg=";
    pname = "dash_table";
  };

  # No tests in archive
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "First-Class Interactive DataTable for Dash";
    homepage = "https://dash.plot.ly/datatable";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
