{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  cryptography,
  poetry-core,
  requests,
}:

buildPythonPackage rec {
  pname = "requests-http-message-signatures";
  version = "0.3.0";

  src = fetchFromGitLab {
    owner = "funkwhale";
    repo = "requests-http-message-signatures";
    tag = version;
    hash = "sha256-1GObY+bF5wwgjDORUlO61bmIadK+EpZtyYGMgS9Bqzg=";
    domain = "dev.funkwhale.audio";
  };

  # Tests require network access.
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    cryptography
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "requests_http_message_signatures" ];

  meta = {
    description = "Request authentication plugin implementing IETF HTTP Message Signatures";
    homepage = "https://dev.funkwhale.audio/funkwhale/requests-http-message-signatures";
    changelog = "https://dev.funkwhale.audio/funkwhale/requests-http-message-signatures/-/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    teams = [ lib.teams.ngi ];
  };
}
