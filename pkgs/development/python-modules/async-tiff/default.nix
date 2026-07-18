{
  lib,
  fetchFromGitHub,
  # utils
  buildPythonPackage,
  # build and dependencies
  llvmPackages,
  maturin,
  numpy,
  obspec,
  obstore,
  pytest-asyncio,
  # tests dependencies
  pytestCheckHook,
  rasterio,
  rustPlatform,
}:
buildPythonPackage (finalAttrs: {
  pname = "async-tiff";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "async-tiff";
    tag = "py-v${finalAttrs.version}";
    hash = "sha256-F2pweyNQMvSZeOn6kNcfk3cPqvaP1d7yAT/ygJvWxjo=";
    fetchSubmodules = true;
  };

  postPatch = ''
    cd python
  '';

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [ llvmPackages.libclang ];
  nativeCheckInputs = [ pytestCheckHook ];

  checkInputs = [
    numpy
    obstore
    pytest-asyncio
    rasterio
  ];

  buildSystem = [ maturin ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    pname = finalAttrs.pname;
    version = finalAttrs.version;
    src = finalAttrs.src;

    preBuild = ''
      cd python
    '';

    hash = "sha256-7iT1ZIdwlztHFEGEseEQEHzY/vqjXX/X6s5Uc3WaKxc=";
  };

  dependencies = [
    obspec
  ];

  disabledTests = [
    # network access
    "test_cog_s3"
    "test_raise_typeerror_fetch_tile_striped_tiff"
  ];

  pyproject = true;
  pythonImportsCheck = [ "async_tiff" ];

  meta = {
    description = "Async TIFF reader for Python";
    homepage = "http://developmentseed.org/async-tiff/";
    license = lib.licenses.mit;
    teams = [ lib.teams.geospatial ];
  };
})
