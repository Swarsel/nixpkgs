{
  lib,
  acme,
  buildPythonPackage,
  certbot,
  fetchPypi,
  pytz,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "certbot-dns-wedos";
  version = "2.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Sle3hoBLwVPF30caCyYtt3raY5Gs9ekg0DthvHxvB4E=";
    pname = "certbot_dns_wedos";
  };

  build-system = [ setuptools ];

  dependencies = [
    certbot
    acme
    requests
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "certbot_dns_wedos" ];

  meta = {
    description = "Wedos DNS Authenticator plugin for Certbot";
    homepage = "https://github.com/clazzor/certbot-dns-wedos";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.tsandrini ];
  };
}
