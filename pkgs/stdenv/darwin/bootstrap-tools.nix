{
  lib,
  stdenv,
  bootstrapTools,
  unpack,
}:

derivation {
  inherit (stdenv.hostPlatform) system;

  PATH = lib.makeBinPath [
    (placeholder "out")
    unpack
  ];

  allowedReferences = [ "out" ];

  args = [
    "${unpack}/bootstrap-tools-unpack.sh"
    bootstrapTools
  ];

  builder = "${unpack}/bin/bash";
  name = "bootstrap-tools";
}
