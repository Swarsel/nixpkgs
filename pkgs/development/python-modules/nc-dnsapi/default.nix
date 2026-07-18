{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
}:

buildPythonPackage rec {
  pname = "nc-dnsapi";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "nbuchwitz";
    repo = "nc_dnsapi";
    rev = "v${version}";
    hash = "sha256-OE4+wJbJbUZ+YB5J5OyvytLFCcrnXCeZEqmphHKKprQ=";
  };

  propagatedBuildInputs = [ requests ];
  # no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "nc_dnsapi" ];

  meta = {
    description = "API wrapper for the netcup DNS api";
    homepage = "https://github.com/nbuchwitz/nc_dnsapi";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      veehaitch
      trundle
    ];
  };
}
