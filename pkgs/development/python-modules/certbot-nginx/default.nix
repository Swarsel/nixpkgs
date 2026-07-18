{
  buildPythonPackage,
  certbot,
  pyparsing,
  setuptools,
}:

buildPythonPackage rec {
  inherit (certbot) src version;
  pname = "certbot-nginx";
  build-system = [ setuptools ];

  dependencies = [
    certbot
    pyparsing
  ];

  pyproject = true;

  pythonImportsCheck = [
    "certbot_nginx"
    "certbot.plugins.nginx"
  ];

  sourceRoot = "${src.name}/certbot-nginx";

  meta = certbot.meta // {
    description = "Nginx plugin for Certbot";
  };
}
