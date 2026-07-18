{
  lib,
  buildPythonPackage,
  callPackage,
  faiss-build,
  numpy,
  packaging,
  pip,
  setuptools,
}:

buildPythonPackage {
  inherit (faiss-build) pname version;
  # E.g. cuda libraries; needed because reference scanning
  # can't see inside the wheels
  inherit (faiss-build) buildInputs;
  src = "${lib.getOutput "dist" faiss-build}";

  postPatch = ''
    mkdir dist
    mv *.whl dist/
  '';

  __structuredAttrs = true;

  build-system = [
    setuptools
    pip
  ];

  dependencies = [
    numpy
    packaging
  ];

  dontBuild = true;
  pyproject = true;
  pythonImportsCheck = [ "faiss" ];

  passthru = {
    inherit (faiss-build) cudaSupport cudaPackages pythonSupport;

    tests = {
      pytest = callPackage ./pytest.nix { inherit faiss-build; };
    };
  };

  meta = lib.pipe (faiss-build.meta or { }) [
    (lib.flip removeAttrs [ "mainProgram" ])
    (m: m // { description = "Bindings for faiss, the similarity search library"; })
  ];
}
