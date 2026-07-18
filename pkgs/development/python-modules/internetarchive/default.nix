{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jsonpatch,
  pytestCheckHook,
  requests,
  responses,
  schema,
  setuptools,
  tqdm,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "internetarchive";
  version = "5.10.1";

  src = fetchFromGitHub {
    owner = "jjjake";
    repo = "internetarchive";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OVjvx7Ne2NLXl5eA1HP89HyoTttR9XAx2AJdXiWMkqY=";
  };

  nativeCheckInputs = [
    responses
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    tqdm
    requests
    jsonpatch
    schema
    urllib3
  ];

  disabledTestPaths = [
    # Tests require network access
    "tests/cli/test_ia.py"
    "tests/cli/test_ia_download.py"
  ];

  disabledTests = [
    # Tests require network access
    "test_get_item_with_kwargs"
    "test_upload"
    "test_upload_metadata"
    "test_upload_queue_derive"
    "test_upload_validate_identifie"
    "test_upload_validate_identifier"
  ];

  pyproject = true;
  pythonImportsCheck = [ "internetarchive" ];

  meta = {
    description = "Python and Command-Line Interface to Archive.org";
    homepage = "https://github.com/jjjake/internetarchive";
    changelog = "https://github.com/jjjake/internetarchive/blob/${finalAttrs.src.tag}/HISTORY.rst";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ pyrox0 ];
    mainProgram = "ia";
  };
})
