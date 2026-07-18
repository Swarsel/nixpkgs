{
  lib,
  fetchFromGitHub,
  bleach,
  buildPythonPackage,
  hatchling,
  jupytext,
  kagglesdk,
  packaging,
  protobuf,
  pytestCheckHook,
  python-dateutil,
  python-dotenv,
  python-slugify,
  requests,
  six,
  tqdm,
  urllib3,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "kaggle";
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "Kaggle";
    repo = "kaggle-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NvSR3kSncBtjj2zuwESGXRMbZofYcnRnXIglRJ3dsrQ=";
  };

  # kaggle authenticates at import time; fake creds for the offline checks.
  env = {
    KAGGLE_KEY = "00000000000000000000000000000000";
    KAGGLE_USERNAME = "nixos-test";
  };

  nativeCheckInputs = [
    pytestCheckHook
    # kaggle creates its config dir at import time; needs a writable HOME.
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    bleach
    jupytext
    kagglesdk
    packaging
    protobuf
    python-dateutil
    python-dotenv
    python-slugify
    requests
    six
    tqdm
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "kaggle" ];

  meta = {
    description = "Official Kaggle CLI";
    homepage = "https://github.com/Kaggle/kaggle-cli";
    changelog = "https://github.com/Kaggle/kaggle-cli/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ daniel-fahey ];
    mainProgram = "kaggle";
  };
})
