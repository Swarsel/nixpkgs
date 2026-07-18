{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  mashumaro,
  numpy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "onedrive-personal-sdk";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "zweckj";
    repo = "onedrive-personal-sdk";
    tag = "v${version}";
    hash = "sha256-V95lfq8GnuitdFbY8MPpX0kyvj8Gx24W2NFeKp0FsSo=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    mashumaro
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "onedrive_personal_sdk" ];

  meta = {
    description = "Package to interact with the Microsoft Graph API for personal OneDrives";
    homepage = "https://github.com/zweckj/onedrive-personal-sdk";
    changelog = "https://github.com/zweckj/onedrive-personal-sdk/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
