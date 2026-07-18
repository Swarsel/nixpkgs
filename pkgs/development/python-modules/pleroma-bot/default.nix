{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  oauthlib,
  pyaml,
  pytestCheckHook,
  requests,
  requests-mock,
  requests-oauthlib,
}:

buildPythonPackage rec {
  pname = "pleroma-bot";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "robertoszek";
    repo = "pleroma-bot";
    rev = version;
    hash = "sha256-vJxblpf3NMSyYMHeWG7vHP5AeluTtMtVxOsHgvGDHeA=";
  };

  propagatedBuildInputs = [
    pyaml
    requests
    requests-oauthlib
    oauthlib
  ];

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pleroma_bot" ];

  meta = {
    description = "Bot for mirroring one or multiple Twitter accounts in Pleroma/Mastodon";
    homepage = "https://robertoszek.github.io/pleroma-bot/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ robertoszek ];
    mainProgram = "pleroma-bot";
  };
}
