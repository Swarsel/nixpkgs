{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-twitch-client";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "tsifrer";
    repo = "python-twitch-client";
    tag = version;
    sha256 = "sha256-gxBpltwExb9bg3HLkz/MNlP5Q3/x97RHxhbwNqqanIM=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ requests ];

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  disabledTests = [
    # Tests require network access
    "test_delete_from_community"
    "test_update"
  ];

  pyproject = true;
  pythonImportsCheck = [ "twitch" ];

  meta = {
    description = "Python wrapper for the Twitch API";
    homepage = "https://github.com/tsifrer/python-twitch-client";
    changelog = "https://github.com/tsifrer/python-twitch-client/blob/${version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
