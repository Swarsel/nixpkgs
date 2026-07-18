{
  lib,
  fetchFromGitHub,
  # dependencies
  attrs,
  boto3,
  buildPythonPackage,
  certifi,
  click,
  click-plugins,
  cligj,
  # build-system
  cython,
  # tests
  fsspec,
  gdal,
  # optional-dependencies
  pyparsing,
  pytestCheckHook,
  pytz,
  setuptools,
  shapely,
  snuggs,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "fiona";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "Toblerity";
    repo = "Fiona";
    tag = finalAttrs.version;
    hash = "sha256-5NN6PBh+6HS9OCc9eC2TcBvkcwtI4DV8qXnz4tlaMXc=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "cython~=3.0.2" cython
  ''
  +
    # pyparsing deprecated parseString in favor of parse_string
    ''
      substituteInPlace fiona/fio/features.py fiona/_vendor/snuggs.py \
        --replace-fail parseString parse_string
    '';

  buildInputs = [ gdal ];

  nativeCheckInputs = [
    fsspec
    pytestCheckHook
    pytz
    shapely
    snuggs
    versionCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.s3;

  # prevent importing local fiona
  preCheck = ''
    rm -r fiona
  '';

  build-system = [
    cython
    gdal # for gdal-config
    setuptools
  ];

  dependencies = [
    attrs
    certifi
    click
    click-plugins
    cligj
  ];

  disabledTestMarks = [
    # Tests with gdal marker do not test the functionality of Fiona,
    # but they are used to check GDAL driver capabilities.
    "gdal"
  ];

  disabledTests = [
    # Some tests access network, others test packaging
    "http"
    "https"
    "wheel"

    # AssertionError: assert """"bool": true""" in data
    "test_write_bool_subtype"

    # AssertionError: assert '"coordinates": [ [ [ -111.74, 42.0 ], [ -111.66, 42.0 ]' in f.read(2000)
    "test_open_kwargs"

    # fiona.errors.DatasetDeleteError: Driver does not support dataset removal operation
    "test_remove"

    # see: https://github.com/Toblerity/Fiona/issues/1273
    "test_append_memoryfile_drivers"
  ];

  optional-dependencies = {
    calc = [
      pyparsing
      shapely
    ];

    s3 = [ boto3 ];
  };

  pyproject = true;

  pytestFlags = [
    # UserWarning: The parameter --where is used more than once. Remove its duplicate as parameters should be unique.
    "-Wignore::UserWarning"
  ];

  pythonImportsCheck = [ "fiona" ];

  meta = {
    description = "OGR's neat, nimble, no-nonsense API for Python";
    homepage = "https://fiona.readthedocs.io/";
    changelog = "https://github.com/Toblerity/Fiona/blob/${finalAttrs.src.tag}/CHANGES.txt";
    license = lib.licenses.bsd3;
    mainProgram = "fio";
    teams = [ lib.teams.geospatial ];
  };
})
