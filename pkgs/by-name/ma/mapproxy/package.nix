{
  lib,
  fetchFromGitHub,

  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mapproxy";
  version = "6.1.1";

  src = fetchFromGitHub {
    owner = "mapproxy";
    repo = "mapproxy";
    tag = finalAttrs.version;
    hash = "sha256-uEnmYL6dzjR5p6MVXW23IJY1tJqfMhCjbHBDnlvaYrE=";
  };

  # Tests are disabled:
  # 1) Dependency list is huge.
  #    https://github.com/mapproxy/mapproxy/blob/master/requirements-tests.txt
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    babel
    boto3 # needed for caches service
    jinja2
    jsonschema
    pillow
    python-dateutil
    pyyaml
    pyproj
    requests
    shapely
    gdal
    lxml
    werkzeug
  ];

  prePatch = ''
    substituteInPlace mapproxy/util/ext/serving.py --replace-warn "args = [sys.executable] + sys.argv" "args = sys.argv"
  '';

  pyproject = true;
  pythonImportsCheck = [ "mapproxy" ];
  pythonRemoveDeps = [ "future" ];

  meta = {
    description = "Open source proxy for geospatial data";
    homepage = "https://mapproxy.org/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rakesh4g ];
    teams = [ lib.teams.geospatial ];
  };
})
