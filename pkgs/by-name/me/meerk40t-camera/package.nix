{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "meerk40t-camera";
  version = "0.1.9";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uGCBHdgWoorVX2XqMCg0YBweb00sQ9ZSbJe8rlGeovs=";
  };

  postPatch = ''
    sed -i '/meerk40t/d' setup.py
  '';

  doCheck = false;

  dependencies = with python3Packages; [
    opencv4
  ];

  format = "setuptools";

  pythonImportsCheck = [
    "camera"
  ];

  meta = {
    description = "MeerK40t camera plugin";
    homepage = "https://github.com/meerk40t/meerk40t-camera";
    license = lib.licenses.mit;
  };
}
