{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mercadopago";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "mercadopago";
    repo = "sdk-python";
    tag = version;
    hash = "sha256-AYgYGY55hhvVY1lB6anJvjRquDRiNoDnpOFTuVdQniM=";
  };

  # require internet
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "mercadopago" ];

  meta = {
    description = "This library provides developers with a simple set of bindings to help you integrate Mercado Pago API to a website and start receiving payments";
    homepage = "https://www.mercadopago.com";
    changelog = "https://github.com/mercadopago/sdk-python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
