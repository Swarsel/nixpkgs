{
  lib,
  buildPythonPackage,
  fetchPypi,
  libvlc,
  replaceVars,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-vlc";
  version = "3.0.21203";

  src = fetchPypi {
    inherit version;
    hash = "sha256-UtBUSydrEeWLbAt0jD4FGPlPdLG0zTKMg6WerKvq0ew=";
    pname = "python_vlc";
  };

  patches = [
    # Patch path for VLC
    (replaceVars ./vlc-paths.patch {
      libvlc = "${libvlc}/lib/libvlc.so.5";
    })
  ];

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "vlc" ];

  meta = {
    description = "Python bindings for VLC, the cross-platform multimedia player and framework";
    homepage = "https://wiki.videolan.org/PythonBinding";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
  };
}
