{
  lib,
  alsa-lib,
  fetchPypi,
  fftw,
  pulseaudio,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "quisk";
  version = "4.2.51";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-BUS9LW64AmOseedjxEA03MT9Sz9dLmOCVE2IXGovXxo=";
  };

  buildInputs = [
    fftw
    alsa-lib
    pulseaudio
  ];

  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    pyusb
    wxpython
  ];

  pyproject = true;
  pythonImportsCheck = [ "quisk" ];

  meta = {
    description = "SDR transceiver for radios that use the Hermes protocol";

    longDescription = ''
      QUISK is a Software Defined Radio (SDR) transceiver. You supply radio
      hardware that converts signals at the antenna to complex (I/Q) data at an
      intermediate frequency (IF). Data can come from a sound card, Ethernet or
      USB. Quisk then filters and demodulates the data and sends the audio to
      your speakers or headphones. For transmit, Quisk takes the microphone
      signal, converts it to I/Q data and sends it to the hardware.

      Quisk can be used with SoftRock, Hermes Lite 2, HiQSDR, Odyssey and many
      radios that use the Hermes protocol. Quisk can connect to digital
      programs like Fldigi and WSJT-X. Quisk can be connected to other software
      like N1MM+ and software that uses Hamlib.
    '';

    homepage = "https://james.ahlstrom.name/quisk/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      pulsation
      kashw2
    ];

    platforms = lib.platforms.linux;
  };
})
