{
  lib,
  fetchFromGitHub,
  absl-py,
  buildPythonPackage,
  fonttools,
  lxml,
  ninja,
  picosvg,
  pillow,
  pngquant,
  pytestCheckHook,
  regex,
  resvg,
  setuptools,
  setuptools-scm,
  toml,
  tomlkit,
  ufo2ft,
  ufolib2,
  zopfli,
}:

buildPythonPackage rec {
  pname = "nanoemoji";
  version = "0.15.9";

  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = "nanoemoji";
    tag = "v${version}";
    hash = "sha256-T/d7gbw8n2I6amp3qAK/uo3Uf1qZ9teVOCIgkiMSkmE=";
  };

  patches = [
    # this is necessary because the tests clear PATH/PYTHONPATH otherwise
    ./test-pythonpath.patch
  ];

  nativeBuildInputs = [
    pngquant
    resvg
  ];

  nativeCheckInputs = [
    pytestCheckHook
    ninja
    picosvg
  ];

  preCheck = ''
    # make sure the built binaries (nanoemoji/maximum_color) can be found by the test
    export PATH="$out/bin:$PATH"
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    absl-py
    fonttools
    lxml
    ninja
    picosvg
    pillow
    regex
    toml
    tomlkit
    ufo2ft
    ufolib2
    zopfli
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        pngquant
        resvg
      ]
    }"
  ];

  pyproject = true;

  # these two packages are just prebuilt wheels containing the respective binaries
  pythonRemoveDeps = [
    "pngquant-cli"
    "resvg-cli"
  ];

  meta = {
    description = "Wee tool to build color fonts";
    homepage = "https://github.com/googlefonts/nanoemoji";
    changelog = "https://github.com/googlefonts/nanoemoji/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ _999eagle ];
  };
}
