{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lib4sbom,
  python-magic,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sbom4files";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "anthonyharrison";
    repo = "sbom4files";
    tag = "v${version}";
    hash = "sha256-2J3JNFtau7U5mNkqxU8Y8wIg2JR7CUZUVX0A4F9tMLs=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    lib4sbom
    python-magic
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sbom4files"
  ];

  meta = {
    description = "SBOM generator for files within a directory";
    homepage = "https://github.com/anthonyharrison/sbom4files";
    changelog = "https://github.com/anthonyharrison/sbom4files/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "sbom4files";
  };
}
