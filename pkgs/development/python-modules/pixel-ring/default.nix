{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyusb,
  setuptools,
  spidev,
  wheel,
}:

buildPythonPackage rec {
  pname = "pixel-ring";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "respeaker";
    repo = "pixel_ring";
    rev = version;
    hash = "sha256-J9kScjD6Xon0YWGxFU881bIbjmDpY7cnWzJ8G0SOKaw=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    pyusb
    spidev
  ];

  doCheck = false; # no tests
  dontUsePythonImportsCheck = true; # requires SPI access
  pyproject = true;

  meta = {
    description = "RGB LED library for ReSpeaker 4 Mic Array, ReSpeaker V2 & ReSpeaker USB 6+1 Mic Array";
    homepage = "https://github.com/respeaker/pixel_ring/tree/master";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "pixel_ring_check";
  };
}
