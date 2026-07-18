{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  numpy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "biopython";
  version = "1.86";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-k6ULWGpNLOxoqy+Z0D71g8V2HY+6VTXLjoHaeB0Nkv8=";
  };

  patches = [
    # Numpy 2.4 compatibility
    (fetchpatch {
      hash = "sha256-oN0nNlhvshIgNrmm+tIeCAJx1U/OqhdL4tj51DV2CHU=";
      url = "https://github.com/biopython/biopython/pull/5161.patch";
    })
  ];

  checkPhase = ''
    runHook preCheck

    export HOME=$(mktemp -d)
    cd Tests
    python run_tests.py --offline

    runHook postCheck
  '';

  build-system = [ setuptools ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "Bio" ];

  meta = {
    description = "Python library for bioinformatics";

    longDescription = ''
      Biopython is a set of freely available tools for biological computation
      written in Python by an international team of developers. It is a
      distributed collaborative effort to develop Python libraries and
      applications which address the needs of current and future work in
      bioinformatics.
    '';

    homepage = "https://biopython.org/wiki/Documentation";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ luispedro ];
  };
}
