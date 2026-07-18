{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  nose2,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-xml-rpc-re";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Croydon";
    repo = "flask-xml-rpc-reloaded";
    tag = version;
    hash = "sha256-S+9Ur22ExgVjKMOKG19cBz2aCVdEyOoS7uoz17CDzd8=";
  };

  nativeCheckInputs = [
    nose2
  ];

  installCheckPhase = ''
    runHook preInstallCheck
    nose2 -v
    runHook postInstallCheck
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    flask
  ];

  format = "setuptools";
  pythonImportsCheck = [ "flask_xmlrpcre" ];

  meta = {
    description = "Let your Flask apps provide XML-RPC APIs";
    homepage = "https://github.com/Croydon/flask-xml-rpc-reloaded";
    changelog = "https://github.com/Croydon/flask-xml-rpc-reloaded/releases/tag/${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      lukegb
    ];
  };
}
