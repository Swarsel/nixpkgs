{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  hatchling,
  ipython,
  pandas,
  plotly,
  requests,
  tqdm,
  unidecode,
}:

buildPythonPackage (finalAttrs: {
  pname = "tcia-utils";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "kirbyju";
    repo = "tcia_utils";
    rev = "9ff8a409df9daaa3f9bc28f0a951d7f6fcb90160"; # Corresponds to v3.2.1
    hash = "sha256-IW6rxlmRj7RW3hM7aZR+BuqboDzp+2R2ObGwAhOxMPM=";
  };

  # Tests require network access to TCIA API and specific credentials
  doCheck = false;

  build-system = [
    hatchling
  ];

  dependencies = [
    beautifulsoup4
    ipython
    pandas
    plotly
    requests
    tqdm
    unidecode
  ];

  pyproject = true;
  pythonImportsCheck = [ "tcia_utils" ];
  pythonRemoveDeps = [ "bs4" ];

  meta = {
    description = "Python utilities for interacting with The Cancer Imaging Archive (TCIA)";
    homepage = "https://github.com/kirbyju/tcia_utils";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sgomezsal ];
  };
})
