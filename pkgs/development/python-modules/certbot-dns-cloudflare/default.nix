{
  acme,
  buildPythonPackage,
  certbot,
  cloudflare,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  inherit (certbot) src version;
  pname = "certbot-dns-cloudflare";
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    acme
    certbot
    cloudflare
  ];

  pyproject = true;

  pytestFlags = [
    "-pno:cacheprovider"

    # Monitor https://github.com/certbot/certbot/issues/9606 for a solution
    "-Wignore::DeprecationWarning"
  ];

  sourceRoot = "${src.name}/certbot-dns-cloudflare";

  meta = certbot.meta // {
    description = "Cloudflare DNS Authenticator plugin for Certbot";
    # https://github.com/certbot/certbot/pull/10182
    broken = true;
  };
}
