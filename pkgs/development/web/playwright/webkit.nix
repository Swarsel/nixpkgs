{
  lib,
  stdenv,
  fetchFromGitHub,
  at-spi2-atk,
  autoPatchelfHook,
  brotli,
  cairo,
  enchant_2,
  fetchpatch,
  fetchzip,
  flite,
  fontconfig,
  freetype,
  glib,
  glib-networking,
  gst_all_1,
  harfbuzz,
  harfbuzzFull,
  hyphen,
  icu74,
  lcms,
  libavif,
  libbacktrace,
  libdrm,
  libepoxy,
  libevent,
  libgbm,
  libgcc,
  libgcrypt,
  libgpg-error,
  libjpeg8,
  libjxl,
  libopus,
  libpng,
  libsoup_3,
  libtasn1,
  libvpx,
  libwebp,
  libwpe,
  libwpe-fdo,
  libxkbcommon,
  libxml2_13,
  libxslt,
  makeWrapper,
  patchelfUnstable,
  revision,
  sqlite,
  system,
  systemdLibs,
  throwSystem,
  wayland-scanner,
  woff2,
  zlib,
}:
let
  download =
    (import ./browser-downloads.nix {
      inherit revision;
      name = "webkit";
    }).${system} or throwSystem;
  libvpx' = libvpx.overrideAttrs (
    finalAttrs: previousAttrs: {
      version = "1.12.0";

      src = fetchFromGitHub {
        owner = "webmproject";
        repo = finalAttrs.pname;
        rev = "v${finalAttrs.version}";
        sha256 = "sha256-9SFFE2GfYYMgxp1dpmL3STTU2ea1R5vFKA1L0pZwIvQ=";
      };
    }
  );
  libjxl' = libjxl.overrideAttrs (
    finalAttrs: previousAttrs: {
      version = "0.8.2";

      src = fetchFromGitHub {
        owner = "libjxl";
        repo = "libjxl";
        rev = "v${finalAttrs.version}";
        hash = "sha256-I3PGgh0XqRkCFz7lUZ3Q4eU0+0GwaQcVb6t4Pru1kKo=";
        fetchSubmodules = true;
      };

      # override split output shenanigans from the main package
      outputs = [
        "out"
        "dev"
      ];

      patches = [
        # Add missing <atomic> content to fix gcc compilation for RISCV architecture
        # https://github.com/libjxl/libjxl/pull/2211
        (fetchpatch {
          hash = "sha256-X4fbYTMS+kHfZRbeGzSdBW5jQKw8UN44FEyFRUtw0qo=";
          url = "https://github.com/libjxl/libjxl/commit/22d12d74e7bc56b09cfb1973aa89ec8d714fa3fc.patch";
        })
      ];

      postPatch = ''
        # Fix multiple definition errors by using C++17 instead of C++11
        substituteInPlace CMakeLists.txt \
          --replace "set(CMAKE_CXX_STANDARD 11)" "set(CMAKE_CXX_STANDARD 17)"
        # Fix the build with CMake 4.
        # See:
        # * <https://github.com/webmproject/sjpeg/commit/9990bdceb22612a62f1492462ef7423f48154072>
        # * <https://github.com/webmproject/sjpeg/commit/94e0df6d0f8b44228de5be0ff35efb9f946a13c9>
        substituteInPlace third_party/sjpeg/CMakeLists.txt \
          --replace-fail \
            'cmake_minimum_required(VERSION 2.8.7)' \
            'cmake_minimum_required(VERSION 3.5...3.10)'
      '';

      cmakeFlags = [
        "-DJPEGXL_FORCE_SYSTEM_BROTLI=ON"
        "-DJPEGXL_FORCE_SYSTEM_HWY=ON"
        "-DJPEGXL_FORCE_SYSTEM_GTEST=ON"
      ]
      ++ lib.optionals stdenv.hostPlatform.isStatic [
        "-DJPEGXL_STATIC=ON"
      ]
      ++ lib.optionals stdenv.hostPlatform.isAarch32 [
        "-DJPEGXL_FORCE_NEON=ON"
      ];

      postInstall = "";
    }
  );
  webkit-linux = stdenv.mkDerivation {
    src = fetchzip {
      inherit (download) url stripRoot;

      hash =
        {
          aarch64-linux = "sha256-qtqMCyEZVQu44HGI73t50D1WcnuzxuxLY7MDzf4NDeA=";
          x86_64-linux = "sha256-GASDnneoxfZLUctJLnaUTPW4HDbKdSamJBxFDVpPUC0=";
        }
        .${system} or throwSystem;
    };

    nativeBuildInputs = [
      autoPatchelfHook
      patchelfUnstable
      makeWrapper
    ];

    buildInputs = [
      at-spi2-atk
      cairo
      enchant_2
      flite
      fontconfig.lib
      freetype
      glib
      brotli
      libjxl'
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-base
      gst_all_1.gstreamer
      harfbuzz
      harfbuzzFull
      hyphen
      icu74
      lcms
      libavif
      libbacktrace
      libdrm
      libepoxy
      libevent
      libgcc
      libgcrypt
      libgpg-error
      libjpeg8
      libopus
      libpng
      libsoup_3
      libtasn1
      libwebp
      libwpe
      libwpe-fdo
      libvpx'
      libxml2_13
      libxslt
      libgbm
      sqlite
      systemdLibs
      wayland-scanner
      woff2.lib
      libxkbcommon
      zlib
    ];

    buildPhase = ''
      cp -R . $out

      # remove unused gtk browser
      rm -rf $out/minibrowser-gtk
      # remove bundled libs
      rm -rf $out/minibrowser-wpe/sys

      wrapProgram $out/minibrowser-wpe/bin/MiniBrowser \
        --prefix GIO_EXTRA_MODULES ":" "${glib-networking}/lib/gio/modules/" \
        --prefix LD_LIBRARY_PATH ":" $out/minibrowser-wpe/lib
    '';

    name = "playwright-webkit";
    patchelfFlags = [ "--no-clobber-old-sections" ];
  };
  webkit-darwin = fetchzip {
    inherit (download) url stripRoot;

    hash =
      {
        aarch64-darwin = "sha256-glVkYnthOFBPp1gZXTue9WwjP+oCgQpq6j9Mlm/bjmg=";
      }
      .${system} or throwSystem;
  };
in
{
  aarch64-darwin = webkit-darwin;
  aarch64-linux = webkit-linux;
  x86_64-linux = webkit-linux;
}
.${system} or throwSystem
