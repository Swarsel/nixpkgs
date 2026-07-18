{
  lib,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  click,
  colorama,
  intelhex,
  packaging,
  pyaml,
  pyftdi,
  pyserial,
  requests,
  schema,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "bcf";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "hardwario";
    repo = "bch-firmware-tool";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xKggVEN3O0umDEt358xc+79/SEVm2peMjfFHGTppTEo=";
  };

  postPatch = ''
    sed -ri 's/@@VERSION@@/${finalAttrs.version}/g' \
      bcf/__init__.py setup.py
  '';

  doCheck = false; # Project provides no tests
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    appdirs
    click
    colorama
    intelhex
    packaging
    pyaml
    pyftdi
    pyserial
    requests
    schema
  ];

  pyproject = true;
  pythonImportsCheck = [ "bcf" ];

  meta = {
    description = "HARDWARIO Firmware Tool";
    homepage = "https://github.com/hardwario/bch-firmware-tool";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cynerd ];
    platforms = lib.platforms.linux;
    mainProgram = "bcf";
  };
})
