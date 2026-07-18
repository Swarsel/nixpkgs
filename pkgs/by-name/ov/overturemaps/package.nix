{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "overturemaps";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-yKl13Y9kRCGHzoqeZIQEac/PrByTCtCQFaz8sUgeVIs=";
  };

  nativeBuildInputs = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    colorama
    geopandas
    numpy
    orjson
    pyarrow
    pyfiglet
    shapely
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "overturemaps" ];
  # Drop once tqdm 4.67.3 reaches master
  pythonRelaxDeps = [ "tqdm" ];

  meta = {
    description = "Official command-line tool of the Overture Maps Foundation";
    homepage = "https://overturemaps.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ crimeminister ];
    mainProgram = "overturemaps";
  };
}
