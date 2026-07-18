{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  feather-format,
  hatchling,
  joblib,
  openpyxl,
  pandas,
  pyarrow,
  requests,
  xlrd,
}:

buildPythonPackage (finalAttrs: {
  pname = "nemosis";
  version = "3.8.1";

  src = fetchFromGitHub {
    owner = "UNSW-CEEM";
    repo = "NEMOSIS";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4Bb9yZUfwkFQVNSVGtg3APXPovos23oHAx4v+6aa7MM=";
  };

  doCheck = false; # require network and patching
  build-system = [ hatchling ];

  dependencies = [
    beautifulsoup4
    feather-format
    joblib
    openpyxl
    pandas
    pyarrow
    requests
    xlrd
  ];

  pyproject = true;
  pythonImportsCheck = [ "nemosis" ];

  meta = {
    description = "Downloader of historical data published by the Australian Energy Market Operator";
    homepage = "https://github.com/UNSW-CEEM/NEMOSIS";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
