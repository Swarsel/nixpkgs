{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  setuptools,
}:

buildPythonPackage rec {
  pname = "drf-spectacular-sidecar";
  version = "2026.1.1";

  src = fetchFromGitHub {
    owner = "tfranzel";
    repo = "drf-spectacular-sidecar";
    tag = version;
    hash = "sha256-8+KfFyGcwA99mSZi95uOqOqzcJUa1GXu0BYva+hJDOw=";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "drf_spectacular_sidecar" ];

  meta = {
    description = "Serve self-contained distribution builds of Swagger UI and Redoc with Django";
    homepage = "https://github.com/tfranzel/drf-spectacular-sidecar";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
