{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_mixer,
  alsa-lib,
  gnutls,
  gzip,
  libGL,
  libjpeg,
  libmad,
  libopus,
  libpng,
  libvorbis,
  libxcb,
  libxcursor,
  libxrandr,
  libxscrnsaver,
  speex,
  vulkan-headers,
  vulkan-loader,
  zlib,
}@attrs:
{
  fteqcc = import ./generic.nix (
    {
      pname = "fteqcc";

      buildInputs = [
        zlib
      ];

      buildFlags = [ "qcc-rel" ];
      description = "User friendly QuakeC compiler";
    }
    // attrs
  );

  fteqw = import ./generic.nix (
    rec {
      pname = "fteqw";

      nativeBuildInputs = [
        vulkan-headers
      ];

      buildInputs = [
        gzip
        libvorbis
        libmad
        SDL2
        SDL2_mixer
        libGL
        libpng
        alsa-lib
        gnutls
        libjpeg
        vulkan-loader
        speex
        libopus
        libxcb
        libxrandr
        libxcursor
        libxscrnsaver
      ];

      buildFlags = [ "m-rel" ];

      postFixup = ''
        patchelf $out/bin/${pname} \
          --add-needed ${SDL2}/lib/libSDL2.so \
          --add-needed ${libGL}/lib/libGLX.so \
          --add-needed ${libGL}/lib/libGL.so \
          --add-needed ${lib.getLib gnutls}/lib/libgnutls.so \
          --add-needed ${vulkan-loader}/lib/libvulkan.so
      '';

      description = "Hybrid and versatile game engine";
    }
    // attrs
  );

  fteqw-dedicated = import ./generic.nix (
    rec {
      pname = "fteqw-dedicated";

      buildInputs = [
        gnutls
        zlib
      ];

      buildFlags = [ "sv-rel" ];

      postFixup = ''
        patchelf $out/bin/${pname} \
          --add-needed ${gnutls}/lib/libgnutls.so
      '';

      description = "Dedicated server for FTEQW";
      releaseFile = "fteqw-sv";
    }
    // attrs
  );
}
