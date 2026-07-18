{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchpatch,
  freebsd,
  updateAutotoolsGnuConfigScriptsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cdparanoia-iii";
  version = "10.2";

  src = fetchurl {
    url = "https://downloads.xiph.org/releases/cdparanoia/cdparanoia-III-${finalAttrs.version}.src.tgz";
    sha256 = "1pv4zrajm46za0f6lv162iqffih57a8ly4pc69f7y0gfyigb8p80";
  };

  patches =
    lib.optionals stdenv.hostPlatform.isDarwin [
      (fetchpatch {
        # Our configure patch will subsume it, but we want our configure
        # patch to be used on all platforms so we cannot just start where
        # this leaves off.
        excludes = [ "configure.in" ];
        hash = "sha256-9p4+9dRvqLHkpR0RWLQcNL1m7fb7L6r+c9Q2tt4jh0U=";
        url = "https://github.com/macports/macports-ports/raw/c8e15973bc3c1e1ab371bc0ee2de14209e639f17/audio/cdparanoia/files/osx_interface.patch";
      })
      (fetchurl {
        hash = "sha256-TW1RkJ0bKaPIrDSfUTKorNlmKDVRF++z8ZJAjSzEgp4=";
        url = "https://trac.macports.org/export/70964/trunk/dports/audio/cdparanoia/files/patch-paranoia_paranoia.c.10.4.diff";
      })
      # add missing include files needed for function prototypes
      (fetchpatch {
        hash = "sha256-6a/u4b8/H/4XjyFup23xySgyAI9SMVMom4PLvH8KzhE=";
        url = "https://github.com/macports/macports-ports/raw/f210a6061bc53c746730a37922399c6de6d69cb7/audio/cdparanoia/files/fixing-include.patch";
      })
    ]
    ++ [
      # Has to come after darwin patches and before freebsd patches
      ./fix_private_keyword.patch
      # Order does not matter
      ./configure.patch
      # labs for long
      (fetchpatch {
        hash = "sha256-BMMQ5bbPP3eevuwWUVjQCtRBiWbkAHD+O0C0fp+BPaw=";
        url = "https://github.com/macports/macports-ports/raw/f210a6061bc53c746730a37922399c6de6d69cb7/audio/cdparanoia/files/fixing-labs.patch";
      })
      # use "%s" for passing a buffer to fprintf
      (fetchpatch {
        hash = "sha256-2dJl16p+f5l3wxVOJhsuLiQ9a4prq7jsRZP8/ygEae4=";
        url = "https://github.com/macports/macports-ports/raw/f210a6061bc53c746730a37922399c6de6d69cb7/audio/cdparanoia/files/fixing-fprintf.patch";
      })
      # add support for IDE4-9
      (fetchpatch {
        hash = "sha256-S6OzftUIPPq9JHsoAE2K51ltsI1WkVaQrpgCjgm5AG4=";
        url = "https://salsa.debian.org/optical-media-team/cdparanoia/-/raw/bbf353721834b3784ccc0fd54a36a6b25181f5a4/debian/patches/02-ide-devices.patch";
      })
      # check buffer is non-null before dereferencing
      (fetchpatch {
        hash = "sha256-krfprwls0L3hsNfoj2j69J5k1RTKEQtzE0fLYG9EJKo=";
        url = "https://salsa.debian.org/optical-media-team/cdparanoia/-/raw/f7bab3024c5576da1fdb7497abbd6abc8959a98c/debian/patches/04-endian.patch";
      })
      ./freebsd.patch
    ]
    ++ lib.optional stdenv.hostPlatform.isMusl ./utils.patch
    ++ lib.optional (!stdenv.hostPlatform.isDarwin) [
      (fetchpatch {
        extraPrefix = "";
        hash = "sha256-bXrcRFCbU7/7/N+J8VGKGSxIB1m8XwoAlc/KTnt9wN0=";

        postFetch = ''
          sed -E -i -e 's/\<Linux\>/__linux__/g' $out
        '';

        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/42da4cdf2d9161fea8f7cdfc19aefda7707fadf4/audio/cdparanoia/files/patch-interface_low__interface.h";
      })
      (fetchpatch {
        extraPrefix = "";
        hash = "sha256-UD7SXeypF3bAqT7Y24UOrGZNaD8ZmpS2V7XQU+3VKXk=";

        postFetch = ''
          sed -E -i -e 's/\<private\>/private_data/g' $out
          sed -E -i -e 's/\<Linux\>/__linux__/g' $out
        '';

        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/42da4cdf2d9161fea8f7cdfc19aefda7707fadf4/audio/cdparanoia/files/patch-interface_scan__devices.c";
      })
      (fetchpatch {
        extraPrefix = "";
        hash = "sha256-JL4qe4LwmNp2jQFqTvyRjc6bixGqYr6BZmqsYIY9xhw=";

        postFetch = ''
          sed -E -i -e 's/\<Linux\>/__linux__/g' $out
        '';

        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/42da4cdf2d9161fea8f7cdfc19aefda7707fadf4/audio/cdparanoia/files/patch-interface_cdda__interface.h";
      })
      (fetchpatch {
        extraPrefix = "";
        hash = "sha256-vw0oFM6w15YBaAK01FwVcSN+oztSfo5jL6OlGy0iWBg=";

        postFetch = ''
          sed -E -i -e 's/\<Linux\>/__linux__/g' $out
        '';

        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/42da4cdf2d9161fea8f7cdfc19aefda7707fadf4/audio/cdparanoia/files/patch-interface_common__interface.c";
      })
      (fetchpatch {
        extraPrefix = "";
        hash = "sha256-g39dhxb8+K9BIb2/5cmkQ9GYjg4gDjj6sv+dXx93kQ4=";

        postFetch = ''
          sed -E -i -e 's/\<Linux\>/__linux__/g' $out
        '';

        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/42da4cdf2d9161fea8f7cdfc19aefda7707fadf4/audio/cdparanoia/files/patch-interface_cooked__interface.c";
      })
      (fetchpatch {
        extraPrefix = "";
        hash = "sha256-LMWfbqLjbQM3L4H3orAxyyAHf1hVtFwfmZY8NmBLKzs=";

        postFetch = ''
          sed -E -i -e 's/\<private\>/private_data/g' $out
          sed -E -i -e 's/\<Linux\>/__linux__/g' $out
        '';

        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/42da4cdf2d9161fea8f7cdfc19aefda7707fadf4/audio/cdparanoia/files/patch-interface_interface.c";
      })
      (fetchpatch {
        extraPrefix = "";
        hash = "sha256-dx6YCWW8J0e455phaYDUMiOCvp4DsfINjSEiEfnHaNI=";

        postFetch = ''
          sed -E -i -e 's/\<private\>/private_data/g' $out
          sed -E -i -e 's/\<Linux\>/__linux__/g' $out
        '';

        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/42da4cdf2d9161fea8f7cdfc19aefda7707fadf4/audio/cdparanoia/files/patch-interface_scsi__interface.c";
      })
      (fetchpatch {
        extraPrefix = "";
        hash = "sha256-Wje2d58xrSWHJNktQRHcNSbh5yh6vMtpgc/3G4D1vrI=";

        postFetch = ''
          sed -E -i -e 's/\<Linux\>/__linux__/g' $out
        '';

        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/42da4cdf2d9161fea8f7cdfc19aefda7707fadf4/audio/cdparanoia/files/patch-Makefile.in";
      })
    ];

  nativeBuildInputs = [
    updateAutotoolsGnuConfigScriptsHook
    autoreconfHook
  ];

  propagatedBuildInputs = lib.optionals stdenv.hostPlatform.isFreeBSD [
    # cdparanoia shipped headers have #include <libcam.h>
    # (it is part of the freebsd base system so this is reasonable
    # but we want to keep the default freebsd libs, freebsd.libc, small)
    freebsd.libcam
  ];

  env =
    lib.optionalAttrs stdenv.hostPlatform.isFreeBSD {
      NIX_LDFLAGS = "-lcam";
    }
    // {
      BSD_INSTALL_LIB = "install";
      BSD_INSTALL_PROGRAM = "install";
    };

  # Build system reuses the same object file names for shared and static
  # library. Occasionally fails in the middle:
  #    gcc -O2 -fsigned-char -g -O2 -c scan_devices.c
  #    rm  -f *.o core *~ *.out
  #    gcc -O2 -fsigned-char -g -O2 -fpic -c scan_devices.c
  #    gcc -fpic -shared -o libcdda_interface.so.0.10.2 ... scan_devices.o ...
  #    scan_devices.o: file not recognized: file format not recognized
  enableParallelBuilding = false;

  meta = {
    description = "Tool and library for reading digital audio from CDs";
    homepage = "https://xiph.org/paranoia";

    license = with lib.licenses; [
      gpl2Plus
      lgpl21Plus
    ];

    maintainers = with lib.maintainers; [
      olduser101
    ];

    platforms = lib.platforms.unix;
    mainProgram = "cdparanoia";
  };
})
