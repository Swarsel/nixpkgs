{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchPypi,
  pandas,
  poetry-core,
  requests,
  zeep,
}:

buildPythonPackage rec {
  pname = "noaa-coops";
  version = "0.4.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-m3hTzUspYTMukwcj3uBbRahTmXbL1aJVD9NXfjwghB8=";
    pname = "noaa_coops";
  };

  # The package does not include tests in the PyPI source distribution
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    pandas
    requests
    zeep
  ];

  pyproject = true;

  pythonImportsCheck = [
    "noaa_coops"
    "noaa_coops.station"
  ];

  meta = {
    description = "Python wrapper for NOAA CO-OPS Tides & Currents Data and Metadata APIs";
    homepage = "https://github.com/GClunies/noaa_coops";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
