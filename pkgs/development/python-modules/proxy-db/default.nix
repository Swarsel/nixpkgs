{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  click,
  pytestCheckHook,
  requests,
  requests-mock,
  six,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "proxy-db";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "Nekmo";
    repo = "proxy-db";
    tag = "v${version}";
    hash = "sha256-NdbvK2sJKKoWNYsuBaCMWtKEvuMhgyKXcKZXQgTC4bY=";
  };

  propagatedBuildInputs = [
    beautifulsoup4
    click
    requests
    six
    sqlalchemy
  ];

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  format = "setuptools";
  pythonImportsCheck = [ "proxy_db" ];

  meta = {
    description = "Module to manage proxies in a local database";
    homepage = "https://github.com/Nekmo/proxy-db/";
    changelog = "https://github.com/Nekmo/proxy-db/blob/v${version}/HISTORY.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "proxy-db";
  };
}
