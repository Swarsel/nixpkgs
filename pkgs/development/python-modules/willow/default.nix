{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  filetype,
  flit-core,
  opencv4,
  pillow,
  pillow-heif,
  pytestCheckHook,
  wand,
}:

buildPythonPackage rec {
  pname = "willow";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "wagtail";
    repo = "Willow";
    tag = "v${version}";
    hash = "sha256-vboQwOEDRdbwmLT2EW1iF98ZuyzEzlrP2k2ZcvVKjFE=";
  };

  nativeCheckInputs = [
    opencv4
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ flit-core ];

  dependencies = [
    filetype
    defusedxml
  ];

  disabledTests = [
    # Flaky: wand.exceptions.MissingDelegateError: no decode delegate for this image format
    "test_gif"
  ];

  optional-dependencies = {
    heif = [ pillow-heif ];
    pillow = [ pillow ];
    wand = [ wand ];
  };

  pyproject = true;

  meta = {
    description = "Python image library that sits on top of Pillow, Wand and OpenCV";
    homepage = "https://github.com/torchbox/Willow/";
    changelog = "https://github.com/wagtail/Willow/releases/tag/v${version}";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      kuflierl
    ];
  };
}
