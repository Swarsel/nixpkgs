{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fcitx5,
  fetchpatch,
  # tests
  mpd,
  openimageio,
  spdlog,
  enableShared ? !stdenv.hostPlatform.isStatic,
}:

let
  generic =
    {
      hash,
      version,
      patches ? [ ],
    }:
    stdenv.mkDerivation {
      inherit version;
      inherit patches;
      pname = "fmt";

      src = fetchFromGitHub {
        inherit hash;
        owner = "fmtlib";
        repo = "fmt";
        rev = version;
      };

      outputs = [
        "out"
        "dev"
      ];

      nativeBuildInputs = [ cmake ];
      cmakeFlags = [ (lib.cmakeBool "BUILD_SHARED_LIBS" enableShared) ];
      doCheck = true;

      passthru.tests = {
        inherit
          mpd
          openimageio
          fcitx5
          spdlog
          ;
      };

      meta = {
        description = "Small, safe and fast formatting library";

        longDescription = ''
          fmt (formerly cppformat) is an open-source formatting library. It can be
          used as a fast and safe alternative to printf and IOStreams.
        '';

        homepage = "https://fmt.dev/";

        changelog =
          let
            ext = if lib.versionOlder version "10" then "rst" else "md";
          in
          "https://github.com/fmtlib/fmt/blob/${version}/ChangeLog.${ext}";

        license = lib.licenses.mit;
        maintainers = [ ];
        platforms = lib.platforms.all;
        downloadPage = "https://github.com/fmtlib/fmt/";
      };
    };
in
{
  fmt_10 = generic {
    version = "10.2.1";
    hash = "sha256-pEltGLAHLZ3xypD/Ur4dWPWJ9BGVXwqQyKcDWVmC3co=";
  };

  fmt_11 = generic {
    version = "11.2.0";

    patches = [
      # Fixes the build with libc++ ≥ 21.
      (fetchpatch {
        hash = "sha256-SJFzNNC0Bt2aEQJlHGc0nv9KOpPQ+TgDX5iuFMUs9tk=";
        url = "https://github.com/fmtlib/fmt/commit/3cabf3757b6bc00330b55975317b2c145e4c689d.patch";
      })
    ];

    hash = "sha256-sAlU5L/olxQUYcv8euVYWTTB8TrVeQgXLHtXy8IMEnU=";
  };

  fmt_12 = generic {
    version = "12.1.0";
    hash = "sha256-ZmI1Dv0ZabPlxa02OpERI47jp7zFfjpeWCy1WyuPYZ0=";
  };

  fmt_9 = generic {
    version = "9.1.0";

    patches = [
      # Fixes the build with Clang ≥ 18.
      (fetchpatch {
        hash = "sha256-YyB5GY/ZqJQIhhGy0ICMPzfP/OUuyLnciiyv8Nscsec=";
        url = "https://github.com/fmtlib/fmt/commit/c4283ec471bd3efdb114bc1ab30c7c7c5e5e0ee0.patch";
      })
    ];

    hash = "sha256-rP6ymyRc7LnKxUXwPpzhHOQvpJkpnRFOt2ctvUNlYI0=";
  };
}
