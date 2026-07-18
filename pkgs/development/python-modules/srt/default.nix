{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "srt";
  version = "3.5.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SIQxUEOk8HQP0fh47WyqN2rAbXDhNfMGptxEYy7tDMA=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "srt" ];

  meta = {
    description = "Tiny but featureful Python library for parsing, modifying, and composing SRT files";
    homepage = "https://github.com/cdown/srt";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
