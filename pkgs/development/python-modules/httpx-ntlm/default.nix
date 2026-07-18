{
  lib,
  buildPythonPackage,
  fetchPypi,
  httpx,
  pyspnego,
}:

buildPythonPackage rec {
  pname = "httpx-ntlm";
  version = "1.4.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Qb6KK6hRQ0hOYX3LkX1LGeOuEq/caIYipJAQNJk7U+Q=";
    pname = "httpx_ntlm";
  };

  propagatedBuildInputs = [
    httpx
    pyspnego
  ];

  # https://github.com/ulodciv/httpx-ntlm/issues/5
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "httpx_ntlm" ];

  meta = {
    description = "NTLM authentication support for HTTPX";
    homepage = "https://github.com/ulodciv/httpx-ntlm";
    changelog = "https://github.com/ulodciv/httpx-ntlm/releases/tag/${version}";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ fab ];
  };
}
