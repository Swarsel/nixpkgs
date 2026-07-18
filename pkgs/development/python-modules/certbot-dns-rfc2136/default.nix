{
  acme,
  buildPythonPackage,
  certbot,
  dnspython,
  pytestCheckHook,
}:

buildPythonPackage rec {
  inherit (certbot) src version;
  pname = "certbot-dns-rfc2136";

  propagatedBuildInputs = [
    acme
    certbot
    dnspython
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";

  pytestFlags = [
    "-pno:cacheprovider"

    # Monitor https://github.com/certbot/certbot/issues/9606 for a solution
    "-Wignore::DeprecationWarning"
  ];

  sourceRoot = "${src.name}/certbot-dns-rfc2136";

  meta = certbot.meta // {
    description = "RFC 2136 DNS Authenticator plugin for Certbot";
  };
}
