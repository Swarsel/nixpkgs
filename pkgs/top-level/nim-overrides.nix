{
  lib,
  stdenv,
  SDL2,
  getdns,
  htslib,
  libsass,
  libx11,
  libxft,
  libxinerama,
  openssl,
  pkg-config,
  raylib,
  tkrzw,
}:

# The following is list of overrides that take two arguments each:
# - lockAttrs: - an attrset from a Nim lockfile, use this for making constraints on the locked library
# - prevAttrs: - preceding arguments to the depender package
{
  getdns =
    lockAttrs:
    {
      buildInputs ? [ ],
      nativeBuildInputs ? [ ],
      ...
    }:
    {
      nativeBuildInputs = nativeBuildInputs ++ [ pkg-config ];
      buildInputs = buildInputs ++ [ getdns ];
    };

  hashlib =
    lockAttrs:
    lib.trivial.warnIf (lockAttrs.rev == "84e0247555e4488594975900401baaf5bbbfb531")
      "the selected version of the hashlib Nim library is hardware specific"
      # https://github.com/khchen/hashlib/pull/4
      # remove when fixed upstream
      (_: { });

  hts =
    lockAttrs:
    {
      buildInputs ? [ ],
      ...
    }:
    {
      buildInputs = buildInputs ++ [ htslib ];
    };

  jester =
    lockAttrs:
    {
      buildInputs ? [ ],
      ...
    }:
    {
      buildInputs = buildInputs ++ [ openssl ];
    };

  nimraylib_now =
    lockAttrs:
    {
      buildInputs ? [ ],
      ...
    }:
    {
      buildInputs = buildInputs ++ [ raylib ];
    };

  sass =
    lockAttrs:
    {
      buildInputs ? [ ],
      ...
    }:
    {
      buildInputs = buildInputs ++ [ libsass ];
    };

  sdl2 =
    lockAttrs:
    {
      buildInputs ? [ ],
      ...
    }:
    {
      buildInputs = buildInputs ++ [ SDL2 ];
    };

  tkrzw =
    lockAttrs:
    {
      buildInputs ? [ ],
      nativeBuildInputs ? [ ],
      ...
    }:
    {
      nativeBuildInputs = nativeBuildInputs ++ [ pkg-config ];
      buildInputs = buildInputs ++ [ tkrzw ];
    };

  x11 =
    lockAttrs:
    {
      buildInputs ? [ ],
      ...
    }:
    {
      buildInputs = buildInputs ++ [
        libx11
        libxft
        libxinerama
      ];
    };

  zippy =
    lockAttrs:
    {
      nimFlags ? [ ],
      ...
    }:
    {
      nimFlags =
        nimFlags
        ++ lib.optionals stdenv.hostPlatform.isx86_64 [
          "--passC:-msse4.1"
          "--passC:-mpclmul"
        ];
    };
}
