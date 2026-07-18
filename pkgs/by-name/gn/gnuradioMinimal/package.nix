{
  gnuradio,
  uhdMinimal,
  volk,
  packageOverrides ? (self: super: { }),
  unwrappedFeaturesOverride ? { },
}:
# A build without gui components and other utilities not needed for end user
# libraries
gnuradio.override {
  inherit packageOverrides;
  doWrap = false;

  unwrapped = gnuradio.unwrapped.override {
    features = {
      doxygen = false;
      examples = false;
      gnuradio-companion = false;
      gr-blocktool = false;
      # Doesn't make it reference python eventually, but makes reverse
      # dependencies require python to use cmake files of GR.
      gr-ctrlport = false;
      gr-modtool = false;
      gr-qtgui = false;
      gr-utils = false;
      python-support = false;
      sphinx = false;
    }
    // unwrappedFeaturesOverride;

    uhd = uhdMinimal;

    volk = volk.override {
      # So it will not reference python
      enableModTool = false;
    };
  };
}
