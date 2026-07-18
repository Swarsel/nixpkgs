{
  lib,
  callPackage,
  stdenvNoCC,
  # Configurable options
  majorVersion ? "9",
}:

let
  sources = callPackage ./sources.nix { };
  pick =
    {
      "10" = sources.nv-codec-headers-10;
      "11" = sources.nv-codec-headers-11;
      "12" = sources.nv-codec-headers-12;
      "8" = sources.nv-codec-headers-8;
      "9" = sources.nv-codec-headers-9;
    }
    .${majorVersion};
in
stdenvNoCC.mkDerivation {
  inherit (pick) pname version src;

  makeFlags = [
    "PREFIX=$(out)"
  ];

  passthru = {
    inherit sources;
  };

  meta = {
    description = "FFmpeg version of headers for NVENC - major version ${pick.version}";
    homepage = "https://ffmpeg.org/";
    license = with lib.licenses; [ mit ];
    maintainers = [ ];
    platforms = lib.platforms.all;
    downloadPage = "https://git.videolan.org/?p=ffmpeg/nv-codec-headers.git";
  };
}
