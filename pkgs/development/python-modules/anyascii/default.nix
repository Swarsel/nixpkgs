{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "anyascii";
  version = "0.3.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-yU6d2dR7PZSU7KMF/vlEfQC0vxoyr/hap0b6Psf7lcM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";

  meta = {
    description = "Unicode to ASCII transliteration";
    homepage = "https://github.com/anyascii/anyascii";
    changelog = "https://github.com/anyascii/anyascii/blob/${version}/CHANGELOG.md";
    license = lib.licenses.isc;
    teams = [ lib.teams.tts ];
  };
}
