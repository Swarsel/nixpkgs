{
  acme,
  buildPythonPackage,
  certbot,
  dns-lexicon,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  inherit (certbot) src version;
  pname = "certbot-dns-ovh";
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    acme
    certbot
    dns-lexicon
  ];

  pyproject = true;

  pytestFlags = [
    "-pno:cacheprovider"

    # Monitor https://github.com/certbot/certbot/issues/9606 for a solution
    "-Wignore::DeprecationWarning"
  ];

  sourceRoot = "${src.name}/certbot-dns-ovh";

  meta = certbot.meta // {
    description = "OVH DNS Authenticator plugin for Certbot";
  };
}
