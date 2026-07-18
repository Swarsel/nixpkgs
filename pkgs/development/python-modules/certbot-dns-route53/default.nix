{
  acme,
  boto3,
  buildPythonPackage,
  certbot,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  inherit (certbot) src version;
  pname = "certbot-dns-route53";
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    acme
    boto3
    certbot
  ];

  pyproject = true;

  pytestFlags = [
    "-pno:cacheprovider"

    # Monitor https://github.com/certbot/certbot/issues/9606 for a solution
    "-Wignore::DeprecationWarning"
  ];

  sourceRoot = "${src.name}/certbot-dns-route53";

  meta = certbot.meta // {
    description = "Route53 DNS Authenticator plugin for Certbot";
  };
}
