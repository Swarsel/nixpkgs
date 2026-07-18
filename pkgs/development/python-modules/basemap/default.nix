{
  lib,
  fetchFromGitHub,
  basemap-data,
  buildPythonPackage,
  cython,
  geos,
  matplotlib,
  numpy,
  pillow,
  pyproj,
  pyshp,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "basemap";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "matplotlib";
    repo = "basemap";
    tag = "v${version}";
    hash = "sha256-1T1FTcR99KbpqiYzrd2r5h1wTcygBEU7BLZXZ8uMthU=";
  };

  nativeBuildInputs = [
    cython
    geos
    setuptools
  ];

  propagatedBuildInputs = [
    basemap-data
    numpy
    matplotlib
    pillow # undocumented optional dependency
    pyproj
    pyshp
  ];

  # Standard configurePhase from `buildPythonPackage` seems to break the setup.py script
  preBuild = ''
    export GEOS_DIR=${geos}
  '';

  # test have various problems including requiring internet connection, permissions issues, problems with latest version of pillow
  doCheck = false;

  checkPhase = ''
    cd ../../examples
    export HOME=$TEMPDIR
    ${python.interpreter} run_all.py
  '';

  format = "setuptools";
  pythonRelaxDeps = true;

  meta = {
    description = "Plot data on map projections with matplotlib";

    longDescription = ''
      An add-on toolkit for matplotlib that lets you plot data on map projections with
      coastlines, lakes, rivers and political boundaries. See
      https://matplotlib.org/basemap/stable/users/examples.html for examples of what it can do.
    '';

    homepage = "https://matplotlib.org/basemap/";

    license = with lib.licenses; [
      mit
      lgpl21
    ];

    teams = [ lib.teams.geospatial ];
  };
}
