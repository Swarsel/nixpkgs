{ copyparty }:
(copyparty.override {
  longDescription = "Almost-full variant, all dependencies and features except those marked buggy";
  nameSuffix = "-most";
  withBasicAudioMetadata = true;
  withCertgen = true;
  withFTP = true;
  withFTPS = true;
  withFastThumbnails = true;
  withHashedPasswords = true;
  withMagic = true;
  withMediaProcessing = true;
  withSMB = false;
  withTFTP = true;
  withThumbnails = true;
  withZeroMQ = true;
}).overrideAttrs
  (old: {
    # don't try to update this package, just update `copyparty`
    # nixpkgs-update: no auto update
    passthru = old.passthru // {
      updateScript = null;
    };

    meta = old.meta // {
      # this serves two purposes: it changes the description, but also makes meta.position point to this file so that the 'no auto update' works
      description = old.meta.description + " - most variant";
    };
  })
