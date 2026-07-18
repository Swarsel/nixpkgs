{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "fluss-api";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "fluss";
    repo = "Fluss_Python_Library";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LXuQUVHssQPA7QTFZm3gqs/WKsDz4HCAyG7ktWIrLBY=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "fluss_api" ];

  meta = {
    description = "Fluss+ API Client";
    homepage = "https://github.com/fluss/Fluss_Python_Library";
    changelog = "https://github.com/fluss/Fluss_Python_Library/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
