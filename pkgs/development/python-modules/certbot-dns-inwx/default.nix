{
  lib,
  fetchFromGitHub,
  acme,
  buildPythonPackage,
  certbot,
  idna,
  inwx-domrobot,
  setuptools,
}:

buildPythonPackage rec {
  pname = "certbot-dns-inwx";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "oGGy990";
    repo = "certbot-dns-inwx";
    tag = "v${version}";
    hash = "sha256-bI/CSTYy/W1AwbxnBxhMp/yFnp68G25mTkNUbdNsRZ4=";
  };

  # Doesn't have any tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    acme
    certbot
    inwx-domrobot
  ];

  optional-dependencies = {
    idna = [ idna ];
  };

  pyproject = true;
  pythonImportsCheck = [ "certbot_dns_inwx" ];

  meta = {
    description = "INWX DNS Authenticator plugin for Certbot";
    homepage = "https://github.com/oGGy990/certbot-dns-inwx";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ onny ];
  };
}
