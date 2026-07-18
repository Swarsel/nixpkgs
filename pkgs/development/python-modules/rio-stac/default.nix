{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build system
  flit,
  # test
  jsonschema,
  # dependencies
  pystac,
  pytestCheckHook,
  rasterio,
  versionCheckHook,
}:

buildPythonPackage rec {
  pname = "rio-stac";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "rio-stac";
    tag = version;
    hash = "sha256-ynpyRYKHHvyoVFU/BgnHPrvRzixXNNw9oOQiOKxSjiI=";
  };

  nativeCheckInputs = [
    jsonschema
    pytestCheckHook
  ];

  build-system = [ flit ];

  dependencies = [
    pystac
    rasterio
  ];

  disabledTests = [
    # urllib url open error
    "test_create_item"
  ];

  pyproject = true;
  pythonImportsCheck = [ "rio_stac" ];

  # the build should should also generate a program for cli, but nothing is installed in $out/bin
  # related comment: https://github.com/NixOS/nixpkgs/pull/392056#issuecomment-2751934248
  meta = {
    description = "Create STAC Items from raster datasets";
    homepage = "https://github.com/developmentseed/rio-stac";
    changelog = "https://github.com/developmentseed/rio-stac/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ daspk04 ];
  };
}
