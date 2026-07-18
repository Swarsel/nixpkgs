{ copyparty }:
(copyparty.override {
  longDescription = "Minimal variant, minimal dependencies and fewest features";
  nameSuffix = "-min";
  withBasicAudioMetadata = false;
  withCertgen = false;
  withFTP = false;
  withFTPS = false;
  withFastThumbnails = false;
  withHashedPasswords = false;
  withMagic = false;
  withMediaProcessing = false;
  withSMB = false;
  withTFTP = false;
  withThumbnails = false;
  withZeroMQ = false;
}).overrideAttrs
  (old: {
    # don't try to update this package, just update `copyparty`
    # nixpkgs-update: no auto update
    passthru = old.passthru // {
      updateScript = null;
    };

    meta = old.meta // {
      # this serves two purposes: it changes the description, but also makes meta.position point to this file so that the 'no auto update' works
      description = old.meta.description + " - minimal variant";
    };
  })
