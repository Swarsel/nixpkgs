{
  lib,
  fetchFromGitHub,
  backoff,
  buildPythonPackage,
  dateutils,
  monotonic,
  requests,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage {
  pname = "june-analytics-python";
  version = "2.3.0-unstable-2022-07-26";

  src = fetchFromGitHub {
    owner = "juneHQ";
    repo = "analytics-python";
    rev = "462b523a617fbadc016ace45e6eec5762a8ae45f";
    hash = "sha256-9IcikYQW1Q3aAyjIZw6UltD6cYFE+tBK+/EMQpRGCoQ=";
  };

  nativeCheckInputs = [
    unittestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    dateutils
    requests
    monotonic
    backoff
  ];

  pyproject = true;
  pythonImportsCheck = [ "june" ];
  pythonRelaxDeps = true;
  unittestFlagsArray = [ "june" ];

  meta = {
    description = "Hassle-free way to integrate analytics into any python application";
    homepage = "https://github.com/juneHQ/analytics-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ soyouzpanda ];
  };
}
