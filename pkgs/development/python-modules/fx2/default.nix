{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  crcmod,
  libusb1,
  sdcc,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "fx2";
  version = "0.14";

  src = fetchFromGitHub {
    owner = "GlasgowEmbedded";
    repo = "libfx2";
    rev = "v${version}";
    hash = "sha256-uMgf1VL3yvkLUfRlBn9NKcerfHfcFg9yEgHGWmwyh8I=";
  };

  nativeBuildInputs = [
    setuptools-scm
    sdcc
  ];

  propagatedBuildInputs = [
    libusb1
    crcmod
  ];

  preBuild = ''
    make -C firmware
    cd software
  '';

  # installCheckPhase tries to run build_ext again and there are no tests
  doCheck = false;

  preInstall = ''
    mkdir -p $out/share/libfx2
    cp -R ../firmware/library/{.stamp,lib,include,fx2{rules,conf}.mk} \
      $out/share/libfx2
  '';

  format = "setuptools";

  meta = {
    description = "Chip support package for Cypress EZ-USB FX2 series microcontrollers";
    homepage = "https://github.com/GlasgowEmbedded/libfx2";
    license = lib.licenses.bsd0;
    maintainers = [ ];
    mainProgram = "fx2tool";
  };
}
