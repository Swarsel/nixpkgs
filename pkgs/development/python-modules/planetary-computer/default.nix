{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  adlfs,
  azure-storage-blob,
  buildPythonPackage,
  # dependencies
  click,
  packaging,
  pydantic,
  pystac,
  pystac-client,
  pytestCheckHook,
  python-dotenv,
  pytz,
  requests,
  # test
  responses,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "planetary-computer";
  version = "1.0.0.post0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "planetary-computer-sdk-for-python";
    tag = "v${version}";
    hash = "sha256-NPHUxThSZzENw4W91WAOqChyIl6Z/Afi4mddz+lXlXA=";
  };

  nativeCheckInputs = [
    responses
    pytestCheckHook
  ]
  ++ optional-dependencies.all;

  build-system = [
    setuptools
  ];

  dependencies = [
    click
    packaging
    pydantic
    pystac
    pystac-client
    python-dotenv
    pytz
    requests
  ];

  disabledTests = [
    # tests require network access
    "test_get_adlfs_filesystem"
    "test_get_container_client"
    "test_signing"
  ];

  optional-dependencies = {
    adlfs = [ adlfs ];
    all = lib.concatAttrValues (lib.removeAttrs optional-dependencies [ "all" ]);
    azure = [ azure-storage-blob ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "planetary_computer"
  ];

  meta = {
    description = "Planetary Computer SDK for Python";
    homepage = "https://github.com/microsoft/planetary-computer-sdk-for-python";
    changelog = "https://github.com/microsoft/planetary-computer-sdk-for-python/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ daspk04 ];
    mainProgram = "planetarycomputer";
  };
}
