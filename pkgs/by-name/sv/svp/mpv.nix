{
  lib,
  mpv,
  mpv-unwrapped,
  ocl-icd,
}:

mpv.override {
  extraMakeWrapperArgs = [
    # Add paths to required libraries
    "--prefix"
    "LD_LIBRARY_PATH"
    ":"
    "/run/opengl-driver/lib:${lib.makeLibraryPath [ ocl-icd ]}"
  ];

  mpv-unwrapped = mpv-unwrapped.override { vapoursynthSupport = true; };
}
