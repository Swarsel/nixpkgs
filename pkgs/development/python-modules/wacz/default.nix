{
  lib,
  fetchFromGitHub,
  boilerpy3,
  buildPythonPackage,
  cdxj-indexer,
  fetchpatch,
  frictionless,
  pytest-cov,
  pytestCheckHook,
  pyyaml,
  setuptools,
  shortuuid,
}:

buildPythonPackage rec {
  pname = "wacz";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "webrecorder";
    repo = "py-wacz";
    tag = "v${version}";
    hash = "sha256-bGY6G7qBAN1Vu+pTNqRG0xh34sR62pMhQFHFGlJaTPQ=";
  };

  patches = [
    # <https://github.com/webrecorder/py-wacz/pull/47>
    (fetchpatch {
      hash = "sha256-zH6BKhsq9ybjzaWcNbVkk1sWh8vVCkv7Qxuwl0MQhNM=";
      name = "clean-up-deps.patch";
      url = "https://github.com/webrecorder/py-wacz/compare/1e8f724a527f28855eedeb0d969ee39b00b2a80a...9d3ad60f125247b8a4354511d9123b85ce6a23c5.patch";
    })
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace "pytest-runner" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    boilerpy3
    cdxj-indexer
    frictionless
    pyyaml
    shortuuid
  ]
  ++ frictionless.optional-dependencies.json;

  disabledTests = [
    # authsign is not packaged
    "test_verify_signed"
  ];

  optional-dependencies = {
    # signing = [
    #   authsign # not packaged
    # ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "wacz"
  ];

  meta = {
    description = "Utility for working with web archive data using the WACZ format specification";
    homepage = "https://github.com/webrecorder/py-wacz";
    changelog = "https://github.com/webrecorder/py-wacz/blob/${src.rev}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zhaofengli ];
    mainProgram = "wacz";
  };
}
