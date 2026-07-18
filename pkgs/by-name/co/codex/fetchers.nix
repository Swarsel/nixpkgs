# not a stable interface, do not reference outside the codex package but make a copy if you need
{
  lib,
  stdenv,
  fetchurl,
}:

{
  fetchLibrustyV8 =
    args:
    fetchurl {
      name = "librusty_v8-${args.version}";
      sha256 = args.shas.${stdenv.hostPlatform.system};
      url = "https://github.com/denoland/rusty_v8/releases/download/v${args.version}/librusty_v8_release_${stdenv.hostPlatform.rust.rustcTarget}.a.gz";

      meta = {
        inherit (args) version;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      };
    };
}
