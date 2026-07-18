{
  lib,
  fetchFromGitHub,
  # dependencies
  build,
  buildPythonPackage,
  hatch-vcs,
  # build-system
  hatchling,
  # tests
  imagemagick,
  jsonschema,
  magicgui,
  # passthru
  napari, # reverse dependency, for tests
  napari-plugin-engine,
  numpy,
  platformdirs,
  psygnal,
  pydantic,
  pydantic-extra-types,
  pytest-pretty,
  pytestCheckHook,
  pyyaml,
  rich,
  tomli,
  tomli-w,
  typer,
}:

buildPythonPackage (finalAttrs: {
  pname = "napari-npe2";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "napari";
    repo = "npe2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cR7hf5v+RgcENY3rSHnOB4E/TONVYvHKS5i3Kv1Sbuc=";
  };

  nativeCheckInputs = [
    imagemagick
    jsonschema
    magicgui
    napari-plugin-engine
    numpy
    pytest-pretty
    pytestCheckHook
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    build
    platformdirs
    psygnal
    pydantic
    pydantic-extra-types
    pyyaml
    rich
    tomli
    tomli-w
    typer
  ];

  disabledTests = [
    # Require internet connection
    "test_cli_fetch"
    "test_fetch_npe1_manifest_dock_widget_as_attribute"
    "test_fetch_npe1_manifest_with_sample_data"
    "test_fetch_npe2_manifest"
    "test_get_manifest_from_wheel"
    "test_get_pypi_url"

    # No package or entry point found with name 'svg'
    "test_cli_convert_svg"
    "test_conversion"
  ];

  pyproject = true;
  pythonImportsCheck = [ "npe2" ];

  passthru.tests = {
    inherit napari;
  };

  meta = {
    description = "Plugin system for napari (the image visualizer)";
    homepage = "https://github.com/napari/npe2";
    changelog = "https://github.com/napari/npe2/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ SomeoneSerge ];
    mainProgram = "npe2";
  };
})
