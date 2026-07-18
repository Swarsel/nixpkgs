{
  acme,
  buildPythonPackage,
  certbot,
  google-api-python-client,
  google-auth,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  inherit (certbot) src version;
  pname = "certbot-dns-google";
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    acme
    certbot
    google-api-python-client
    google-auth
  ];

  pyproject = true;

  pytestFlags = [
    "-pno:cacheprovider"
  ];

  sourceRoot = "${src.name}/certbot-dns-google";

  meta = certbot.meta // {
    description = "Google Cloud DNS Authenticator plugin for Certbot";
  };
}
