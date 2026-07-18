{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bluez,
  cmake,
  curl,
  grantlee,
  hidapi,
  libgit2,
  libsForQt5,
  libssh2,
  libusb1,
  libxcomposite,
  libxml2,
  libxslt,
  libzip,
  pkg-config,
  writeScript,
  writeShellScriptBin,
  zlib,
}:

let
  version = "6.0.5576";

  subsurfaceSrc = (
    fetchFromGitHub {
      fetchSubmodules = true;
      hash = "sha256-ILy5M2m2rKPP77x7cMiqNzpd6NOnQS8UpqZemf/SHf4=";
      owner = "Subsurface";
      repo = "subsurface";
      rev = "87a5ba9fd00712e71b90115b7566d4228a5c0d98";
    }
  );

  libdc = stdenv.mkDerivation {
    inherit version;
    pname = "libdivecomputer-ssrf";
    src = subsurfaceSrc;

    nativeBuildInputs = [
      autoreconfHook
      pkg-config
    ];

    buildInputs = [
      zlib
      libusb1
      bluez
      hidapi
    ];

    enableParallelBuilding = true;
    sourceRoot = "${subsurfaceSrc.name}/libdivecomputer";

    meta = {
      description = "Cross-platform and open source library for communication with dive computers from various manufacturers";
      homepage = "https://www.libdivecomputer.org";
      license = lib.licenses.lgpl21;
      maintainers = with lib.maintainers; [ mguentner ];
      platforms = lib.platforms.all;
    };
  };

  googlemaps = stdenv.mkDerivation rec {
    pname = "googlemaps";
    version = "0.0.0.2";

    src = fetchFromGitHub {
      owner = "vladest";
      repo = "googlemaps";
      rev = "v.${version}";
      hash = "sha256-PfSLFQeCeVNcCVDCZehxyNLQGT6gff5jNxMW8lAaP8c=";
    };

    nativeBuildInputs = [ libsForQt5.qmake ];

    buildInputs = [
      libsForQt5.qtbase
      libsForQt5.qtlocation
      libxcomposite
    ];

    installPhase = ''
      mkdir -p $out $(dirname ${pluginsSubdir}/geoservices)
      mkdir -p ${pluginsSubdir}/geoservices
      mv *.so ${pluginsSubdir}/geoservices
      mv lib $out/
    '';

    dontWrapQtApps = true;
    pluginsSubdir = "lib/qt-${libsForQt5.qtbase.qtCompatVersion}/plugins";

    meta = {
      inherit (src.meta) homepage;
      description = "QtLocation plugin for Google maps tile API";
      license = lib.licenses.mit;
      maintainers = [ ];
      platforms = lib.platforms.all;
    };
  };

  get-version = writeShellScriptBin "get-version" ''
    echo -n ${version}
  '';

in
stdenv.mkDerivation {
  inherit version;
  pname = "subsurface";
  src = subsurfaceSrc;

  postPatch = ''
    install -m555 -t scripts ${lib.getExe get-version}
  '';

  nativeBuildInputs = [
    cmake
    libsForQt5.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    bluez
    curl
    googlemaps
    grantlee
    libdc
    libgit2
    libssh2
    libxml2
    libxslt
    libzip
    libsForQt5.qtbase
    libsForQt5.qtconnectivity
    libsForQt5.qtsvg
    libsForQt5.qttools
    libsForQt5.qtpositioning
  ];

  cmakeFlags = [
    "-DLIBDC_FROM_PKGCONFIG=ON"
    "-DNO_PRINTING=OFF"
  ];

  passthru = {
    inherit version libdc googlemaps;

    updateScript = writeScript "update-subsurface" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p git common-updater-scripts

      set -eu -o pipefail
      tmpdir=$(mktemp -d)
      pushd $tmpdir
      git clone -b current https://github.com/subsurface/subsurface.git
      cd subsurface
      sed -i '1s/#!\/bin\/bash/#!\/usr\/bin\/env bash/' ./scripts/get-version.sh
      # this returns 6.0.????-local
      new_version=$(./scripts/get-version.sh | cut -d '-' -f 1)
      new_rev=$(git rev-list -1 HEAD)
      popd
      update-source-version subsurface "$new_version" --rev="$new_rev"
      rm -rf $tmpdir
    '';
  };

  meta = {
    description = "Divelog program";

    longDescription = ''
      Subsurface can track single- and multi-tank dives using air, Nitrox or TriMix.
      It allows tracking of dive locations including GPS coordinates (which can also
      conveniently be entered using a map interface), logging of equipment used and
      names of other divers, and lets users rate dives and provide additional notes.
    '';

    homepage = "https://subsurface-divelog.org";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ mguentner ];
    platforms = lib.platforms.all;
    mainProgram = "subsurface";
  };
}
