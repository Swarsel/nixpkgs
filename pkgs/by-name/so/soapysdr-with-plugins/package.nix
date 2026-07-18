{
  lib,
  limesuite,
  soapyairspy,
  soapyaudio,
  soapybladerf,
  soapyhackrf,
  soapyplutosdr,
  soapyremote,
  soapyrtlsdr,
  soapysdr,
  soapyuhd,
  stdenvNoCC,
  python ? null,
  usePython ? false,
}:

soapysdr.override {
  inherit python usePython;

  extraPackages = [
    limesuite
    soapyairspy
    soapyaudio
    soapybladerf
    soapyhackrf
    soapyplutosdr
    soapyremote
    soapyrtlsdr
  ]
  ++ (lib.optionals stdenvNoCC.hostPlatform.isLinux [
    soapyuhd
  ]);
}
