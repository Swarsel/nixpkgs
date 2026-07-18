{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bnnumerizer";
  version = "0.0.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Qd9v0Le1GqTsR3a2ZDzt6+5f0R4zXX1W1KIMCFFeXw0=";
  };

  # https://github.com/mnansary/bnUnicodeNormalizer/issues/10
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "bnnumerizer" ];

  meta = {
    description = "Bangla Number text to String Converter";
    homepage = "https://github.com/banglakit/number-to-bengali-word";
    license = lib.licenses.mit;
    teams = [ lib.teams.tts ];
  };
})
