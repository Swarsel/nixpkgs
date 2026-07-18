{
  lib,
  buildPythonPackage,
  fetchPypi,
  protobuf,
  setuptools,
}:

buildPythonPackage rec {
  pname = "snakebite";
  version = "2.11.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CFI4tJRMucZY7mLVeU3pNqw9DDN8UEssyGQkogWul4o=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'argparse'" ""
  '';

  # Tests require hadoop hdfs
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ protobuf ];
  pyproject = true;
  pythonImportsCheck = [ "snakebite" ];

  meta = {
    description = "Pure Python HDFS client";
    homepage = "https://github.com/spotify/snakebite";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "snakebite";
  };
}
