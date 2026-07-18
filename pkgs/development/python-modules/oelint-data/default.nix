{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  oelint-parser,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "oelint-data";
  version = "1.5.9";

  src = fetchFromGitHub {
    owner = "priv-kweihmann";
    repo = "oelint-data";
    tag = finalAttrs.version;
    hash = "sha256-kVTuRhP9T6kyhgavLsKtxNQz/7fW7LYDLR23rj+WGRM=";
  };

  # No tests
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    oelint-parser
  ];

  pyproject = true;
  pythonImportsCheck = [ "oelint_data" ];

  meta = {
    description = "Data for oelint-adv";
    homepage = "https://github.com/priv-kweihmann/oelint-data";
    changelog = "https://github.com/priv-kweihmann/oelint-data/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
