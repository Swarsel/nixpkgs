{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  future,
  pyjwt,
  requests,
  requests-toolbelt,
  setuptools,
  versioneer,
}:

buildPythonPackage rec {
  pname = "webexteamssdk";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "CiscoDevNet";
    repo = "webexteamssdk";
    tag = "v${version}";
    hash = "sha256-xlkmXl4tVm48drXmkUijv9GNXzJcDnfSKbOMciPIRRo=";
  };

  postPatch = ''
    # Remove vendorized versioneer
    rm versioneer.py
  '';

  # Tests require a Webex Teams test domain
  doCheck = false;

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [
    future
    pyjwt
    requests
    requests-toolbelt
  ];

  pyproject = true;
  pythonImportsCheck = [ "webexteamssdk" ];
  # opsdroid still depends on webexteamssdk but package was renamed
  # to webexpythonsdk
  passthru.skipBulkUpdate = true;

  meta = {
    description = "Python module for Webex Teams APIs";
    homepage = "https://github.com/CiscoDevNet/webexteamssdk";
    changelog = "https://github.com/WebexCommunity/WebexPythonSDK/releases/tag/v${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
