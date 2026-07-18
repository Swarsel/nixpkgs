{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  geoarrow-types,
  numpy,
  pandas,
  pyarrow,
  pytestCheckHook,
  rustPlatform,
}:
let
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "kylebarron";
    repo = "arro3";
    tag = "py-v${version}";
    hash = "sha256-24aMiFHQdwZwTthPt7GILjQzbbLp3K2UcXYw3ZGWUJ4=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit version src;
    pname = "arro3-vendor";
    hash = "sha256-8pD7vfGtwknUKLQ/DARmRvvnffBqbGLY9lWJgU7VvWM=";
  };

  commonMeta = {
    changelog = "https://github.com/kylebarron/arro3/releases/tag/py-v${version}";
    homepage = "https://github.com/kylebarron/arro3";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.mslingsby ];
  };

  buildArro3Package =
    {
      description,
      pname,
      pythonImportsCheck,
      subdir,
      dependencies ? [ ],
    }:
    buildPythonPackage {
      inherit
        pname
        version
        src
        cargoDeps
        dependencies
        pythonImportsCheck
        ;

      nativeBuildInputs = with rustPlatform; [
        cargoSetupHook
        maturinBuildHook
      ];

      env = {
        CARGO_TARGET_DIR = "./target";
      };

      cargoRoot = "..";
      pyproject = true;
      sourceRoot = "${src.name}/${subdir}";
      # Avoid infinite recursion in tests.
      # arro3-core tests depends on arro3-compute and arro3-compute depends on arro3-core
      passthru.tests = { inherit arro3-tests; };

      meta = commonMeta // {
        inherit description;
      };
    };

  arro3-core = buildArro3Package {
    pname = "arro3-core";
    description = "Core library for representing Arrow data in Python";
    pythonImportsCheck = [ "arro3.core" ];
    subdir = "arro3-core";
  };

  arro3-compute = buildArro3Package {
    pname = "arro3-compute";
    dependencies = [ arro3-core ];
    description = "Rust-based compute kernels for Arrow in Python";
    pythonImportsCheck = [ "arro3.compute" ];
    subdir = "arro3-compute";
  };

  arro3-io = buildArro3Package {
    pname = "arro3-io";
    dependencies = [ arro3-core ];
    description = "Rust-based readers and writers for Arrow in Python";
    pythonImportsCheck = [ "arro3.io" ];
    subdir = "arro3-io";
  };

  arro3-tests = buildPythonPackage {
    inherit src;
    pname = "arro3-tests";
    version = arro3-core.version;

    nativeCheckInputs = [
      pytestCheckHook
      geoarrow-types
      pandas
      pyarrow
      numpy
      arro3-core
      arro3-compute
      arro3-io
    ];

    dontBuild = true;
    dontInstall = true;
    pyproject = false;
  };
in
{
  inherit arro3-core arro3-io arro3-compute;
}
