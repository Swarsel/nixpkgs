{
  lib,
  fetchPypi,
  python3Packages,
}:

let
  version = "2.0.3";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "ddsmt";

  src = fetchPypi {
    inherit version;
    hash = "sha256-nmhEG4sUmgpgRUduVTtwDLGPJVKx+dEaPb+KjFRwV2Q=";
    pname = "ddSMT";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    gprof2dot
    progressbar
  ];

  pyproject = true;

  meta = {
    description = "Delta debugger for SMT benchmarks in SMT-LIB v2";
    homepage = "https://ddsmt.readthedocs.io/";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = [ ];
  };
}
