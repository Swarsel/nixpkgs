{
  lib,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  httpx,
  packaging,
  # build-system
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "wapiti-arsenic";
  version = "28.5";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-snIKEdrBOIfPeHkVLv0X5lsBzDbOtDrbOj4m8UNCj60=";
    pname = "wapiti_arsenic";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "poetry>=2.1.3" "poetry-core" \
      --replace-fail "poetry.masonry" "poetry.core.masonry"
  '';

  # No tests in the pypi archive
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    httpx
    packaging
  ];

  pyproject = true;
  pythonImportsCheck = [ "wapiti_arsenic" ];
  pythonRelaxDeps = [ "packaging" ];

  meta = {
    description = "Asynchronous WebDriver client";
    homepage = "https://github.com/wapiti-scanner/arsenic";
    changelog = "https://github.com/wapiti-scanner/arsenic/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
