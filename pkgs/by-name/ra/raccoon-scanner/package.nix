{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "raccoon-scanner";
  version = "0.8.5-unstable-2025-06-10";

  src = fetchFromGitHub {
    owner = "evyatarmeged";
    repo = "Raccoon";
    rev = "44024abaa6ca420b6b2c6f06285df306f360eb22";
    hash = "sha256-jcZKjQR92brWcB1+WSKkpoE0V5TLkfDCRu8TQY/hkoc=";
  };

  # Project has no test
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    beautifulsoup4
    click
    dnspython
    fake-useragent
    lxml
    pysocks
    requests
    setuptools
    xmltodict
  ];

  pyproject = true;

  meta = {
    description = "Tool for reconnaissance and vulnerability scanning";
    homepage = "https://github.com/evyatarmeged/Raccoon";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "raccoon";
  };
})
