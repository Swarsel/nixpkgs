{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pynfsclient";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "Pennyw0rth";
    repo = "NfsClient";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9PV/RpK/rOI9jpTDy0FmkXY2Cf54vve6j1kM5dcZgV8=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pyNfsClient" ];

  meta = {
    description = "Pure python library to simulate NFS client";
    homepage = "https://github.com/Pennyw0rth/NfsClient";
    changelog = "https://github.com/Pennyw0rth/NfsClient/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fab
      letgamer
    ];
  };
})
