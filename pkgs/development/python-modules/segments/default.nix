{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  csvw,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  regex,
  setuptools,
}:

buildPythonPackage rec {
  pname = "segments";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "cldf";
    repo = "segments";
    rev = "v${version}";
    sha256 = "sha256-XhJH87Bb9wGNPpPymRjgPYLv2zr4hGAyIAbTMk0uCU0=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    regex
    csvw
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-mock
  ];

  pyproject = true;

  meta = {
    description = "Unicode Standard tokenization routines and orthography profile segmentation";
    homepage = "https://github.com/cldf/segments";
    changelog = "https://github.com/cldf/segments/blob/${src.rev}/CHANGES.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "segments";
  };
}
