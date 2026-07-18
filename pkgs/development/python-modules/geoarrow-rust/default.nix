{
  lib,
  fetchFromGitHub,
  # tests
  arro3-compute,
  arro3-core,
  arro3-io,
  buildPythonPackage,
  geoarrow-types,
  geodatasets,
  geopandas,
  numpy,
  obstore,
  pandas,
  pyarrow,
  pyogrio,
  pyproj,
  pytest-asyncio,
  pytestCheckHook,
  rustPlatform,
  shapely,
}:
let
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "geoarrow";
    repo = "geoarrow-rs";
    tag = "py-v${version}";
    hash = "sha256-5RWhOw31yRzkBE27LeES7z3G7OgRHQZP3aYacBuPUDM=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src version;
    pname = "geoarrow-rust-vendor";
    cargoRoot = "python";
    hash = "sha256-HbtNzcFkqDS8RpxW6MBfOhhzy5MsaKguKkhDN5xGckY=";
  };

  commonMeta = {
    changelog = "https://github.com/geoarrow/geoarrow-rs/releases/tag/py-v${version}";
    homepage = "https://github.com/geoarrow/geoarrow-rs";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ daspk04 ];
  };

  buildGeoArrowPackage =
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

      postPatch = ''
        chmod -R +w ../..
      '';

      nativeBuildInputs = with rustPlatform; [
        cargoSetupHook
        maturinBuildHook
      ];

      # set target directory so maturin can find the compiled libraries in this workspace setup
      env = {
        CARGO_TARGET_DIR = "./target";
      };

      __structuredAttrs = true;
      cargoRoot = "..";
      pyproject = true;
      sourceRoot = "${src.name}/python/${subdir}";
      passthru.tests = { inherit geoarrow-rust-tests; };

      meta = commonMeta // {
        inherit description;
      };
    };

  geoarrow-rust-core = buildGeoArrowPackage {
    pname = "geoarrow-rust-core";

    dependencies = [
      arro3-core
      pyproj
    ];

    description = "Core library for representing GeoArrow data in Python";
    pythonImportsCheck = [ "geoarrow.rust.core" ];
    subdir = "geoarrow-core";
  };

  geoarrow-rust-io = buildGeoArrowPackage {
    pname = "geoarrow-rust-io";

    dependencies = [
      arro3-core
      obstore
      pyproj
    ];

    description = "Rust-based readers and writers for GeoArrow in Python";
    pythonImportsCheck = [ "geoarrow.rust.io" ];
    subdir = "geoarrow-io";
  };

  geoarrow-rust-tests = buildPythonPackage {
    inherit src version;
    pname = "geoarrow-rust-tests";

    # fix the directory name, as it is named as source for nix build
    postPatch = ''
      substituteInPlace python/tests/utils.py \
        --replace-fail 'while current_dir.stem != "geoarrow-rs":' 'while current_dir.stem != "source":'
    '';

    nativeCheckInputs = [
      arro3-compute
      arro3-io
      geoarrow-rust-core
      geoarrow-rust-io
      geoarrow-types
      geodatasets
      geopandas
      numpy
      obstore
      pandas
      pyarrow
      pyogrio
      pytest-asyncio
      pytestCheckHook
      shapely
    ];

    disabledTests = [
      # require internet access to download datasets
      "test_parse_nybb"
      "test_parse_nybb_chunked"
      "test_getitem"
      "test_geo_interface_polygon"
      "test_parquet_file"
    ];

    dontBuild = true;
    dontInstall = true;
    pyproject = false;
    # use the latest test folder (skips the tests_old folder)
    pytestFlags = [ "python/tests" ];
  };
in
{
  inherit geoarrow-rust-core geoarrow-rust-io;
}
