{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchbzr,
  libsForQt5,
  versionNum ? "1.1.0",
}:

let
  versionInfo = {
    "0.4.15" = rec {
      src = fetchbzr {
        inherit rev;
        # the branch name does not mach the version for some reason
        url = "https://code.launchpad.net/~arcachofo/simulide/simulide_0.4.14";
        sha256 = "sha256-BBoZr/S2pif0Jft5wrem8y00dXl08jq3kFiIUtOr3LM=";
      };

      release = "SR10";
      rev = "291";
    };

    "1.0.0" = rec {
      src = fetchbzr {
        inherit rev;
        url = "https://code.launchpad.net/~arcachofo/simulide/1.0.0";
        sha256 = "sha256-rJWZvnjVzaKXU2ktbde1w8LSNvu0jWkDIk4dq2l7t5g=";
      };

      release = "SR2";
      rev = "1449";
    };

    "1.1.0" = rec {
      src = fetchFromGitHub {
        inherit rev;
        owner = "Arcachofo";
        repo = "SimuliDE_110";
        hash = "sha256-Ec72OE4xBlanFFzrrGu0lTY2BEVu7slc1+ZDFr8lUT8=";
      };

      release = "SR2";
      rev = "28965e3bd6dd118598db1f5639ce1cf2e3c56e36";
    };

    "1.2.0" = rec {
      src = fetchFromGitHub {
        inherit rev;
        owner = "Arcachofo";
        repo = "SimulIDE-dev";
        hash = "sha256-6Gh0efBizDK1rUNkyU+/ysj7QwkAs3kTA1mQZYFb/pI=";
      };

      release = "RC1";
      rev = "da3a925491fab9fa2a8633d18e45f8e1b576c9d2";
    };
  };
in

let
  inherit (versionInfo.${versionNum} or (throw "Unsupported versionNum")) release rev src;

  iconPath =
    if lib.versionOlder versionNum "1.0.0" then
      "resources/icons/hicolor/256x256/simulide.png" # upstream had a messed up icon path in this release
    else
      "resources/icons/simulide.png";

  release' = lib.optionalString (lib.versionOlder versionNum "1.2.0") "-" + release;
in

stdenv.mkDerivation {
  inherit src;
  pname = "simulide";
  version = "${versionNum}-${release}";

  patches = lib.optionals (versionNum == "1.0.0") [
    # a static field was declared as protected but was accessed
    # from a place where it would have had to be public
    # this is only an error when using clang, gcc is more lenient
    ./clang-fix-protected-field.patch
  ];

  postPatch = ''
    sed -i resources/simulide.desktop \
      -e "s|^Exec=.*$|Exec=simulide|" \
      -e "s|^Icon=.*$|Icon=simulide|"

    # Note: older versions don't have REV_NO
    # Note: the project file hardcodes a homebrew gcc compiler when using darwin
    #       which we don't want, so we just delete the relevant lines
    sed -i SimulIDE.pr* \
      -e "s|^VERSION = .*$|VERSION = ${versionNum}|" \
      -e "s|^RELEASE = .*$|RELEASE = ${release'}|" \
      -e "s|^REV_NO = .*$|REV_NO = ${rev}|" \
      -e "s|^BUILD_DATE = .*$|BUILD_DATE = ??????|" \
      -e "/QMAKE_CC/d" \
      -e "/QMAKE_CXX/d" \
      -e "/QMAKE_LINK/d"

    ${lib.optionalString (lib.versionOlder versionNum "1.0.0") ''
      # GCC 13 needs the <cstdint> header explicitly included
      sed -i src/gpsim/value.h -e '1i #include <cstdint>'
      sed -i src/gpsim/modules/watchdog.h -e '1i #include <cstdint>'
    ''}
  '';

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtserialport
    libsForQt5.qtmultimedia
    libsForQt5.qttools
  ]
  ++ lib.optionals (lib.versionOlder versionNum "1.1.0") [
    libsForQt5.qtscript
  ];

  preConfigure = ''
    cd build_XX
  '';

  installPhase = ''
    runHook preInstall

    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      install -Dm644 ../resources/simulide.desktop $out/share/applications/simulide.desktop
      install -Dm644 ../${iconPath} $out/share/icons/hicolor/256x256/apps/simulide.png
    ''}

    pushd executables/SimulIDE_*
    ${
      if stdenv.hostPlatform.isDarwin then
        ''
          mkdir -p $out/Applications
          cp -r simulide.app $out/Applications
        ''
      else if lib.versionOlder versionNum "1.0.0" then
        ''
          mkdir -p $out/share/simulide $out/bin
          cp -r share/simulide/* $out/share/simulide
          cp bin/simulide $out/bin/simulide
        ''
      else
        ''
          mkdir -p $out/share/simulide $out/bin
          cp -r data examples $out/share/simulide
          cp simulide $out/bin/simulide
        ''
    }
    popd

    runHook postInstall
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/bin
    wrapQtApp $out/Applications/simulide.app/Contents/MacOs/simulide
    ln -s $out/Applications/simulide.app/Contents/MacOs/simulide $out/bin/simulide
  '';

  # on darwin there are some binaries in the examples directory which
  # accidentally get wrapped by wrapQtAppsHook so we do the wrapping manually instead
  dontWrapQtApps = stdenv.hostPlatform.isDarwin;

  meta = {
    description = "Simple real time electronic circuit simulator";

    longDescription = ''
      SimulIDE is a simple real time electronic circuit simulator, intended for hobbyist or students
      to learn and experiment with analog and digital electronic circuits and microcontrollers.
      It supports PIC, AVR, Arduino and other MCUs and MPUs.
    '';

    homepage = "https://simulide.com/";

    license =
      if lib.versionAtLeast versionNum "1.1.0" then lib.licenses.agpl3Only else lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      carloscraveiro
      tomasajt
    ];

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "simulide";
  };
}
