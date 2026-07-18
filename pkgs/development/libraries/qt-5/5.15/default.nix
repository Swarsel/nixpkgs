/*
  # Updates

  Run `./fetch.sh` to update package sources from Git.
  Check for any minor version changes.
*/

{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  callPackages,
  config,
  darwin,
  fetchgit,
  fetchpatch,
  gcc14Stdenv,
  generateSplicesForMkScope,
  llvmPackages_19,
  makeScopeWithSplicing',
  makeSetupHook,
  python3,
  debug ? false,
  decryptSslTraffic ? false,
  # options
  developerBuild ? false,
}:

let

  srcs = import ./srcs.nix { inherit lib fetchgit fetchFromGitHub; };

  qtCompatVersion = srcs.qtbase.version;

  patches = {
    qtbase = [
      ./qtbase.patch.d/0003-qtbase-mkspecs.patch
      ./qtbase.patch.d/0004-qtbase-replace-libdir.patch
      ./qtbase.patch.d/0005-qtbase-cmake.patch
      ./qtbase.patch.d/0006-qtbase-gtk3.patch
      ./qtbase.patch.d/0007-qtbase-xcursor.patch
      ./qtbase.patch.d/0008-qtbase-tzdir.patch
      ./qtbase.patch.d/0009-qtbase-qtpluginpath.patch
      ./qtbase.patch.d/0010-qtbase-assert.patch
      ./qtbase.patch.d/0011-fix-header_module.patch
      (fetchpatch {
        hash = "sha256-BnpejF6/L73kVVts0R0/OMbVN8G4DXVFwBMJPLU9QbE=";
        name = "0012-qtbase-loongarch64.patch";
        url = "https://gitlab.alpinelinux.org/alpine/aports/-/raw/81b14ae4eed038662b53cd20786fd5e0816279ec/community/qt5-qtbase/loongarch64.patch";
      })
      (fetchpatch {
        hash = "sha256-tzmmLmMXmeDwRVjdpWekDJvSkrIIlslC12HP7XPcm3E=";
        url = "https://salsa.debian.org/qt-kde-team/qt/qtbase/-/raw/6910758e1141f8ea65a8f2359ac30163d65bf6e2/debian/patches/cross_build_mysql.diff";
      })
    ];

    qtdeclarative = [
      ./qtdeclarative.patch
      # prevent headaches from stale qmlcache data
      ./qtdeclarative-default-disable-qmlcache.patch
      # add version specific QML import path
      ./qtdeclarative-qml-paths.patch
    ];

    qtlocation = lib.optionals stdenv.cc.isClang [
      # Fix build with Clang 16
      (fetchpatch {
        extraPrefix = "src/3rdparty/mapbox-gl-native/deps/boost/1.65.1/";
        hash = "sha256-UEvIXzn387f9BAeBdhheStD/4M7en+rmqX8C6gstl6k=";
        stripLen = 1;
        url = "https://github.com/boostorg/numeric_conversion/commit/50a1eae942effb0a9b90724323ef8f2a67e7984a.patch";
      })
    ];

    qtpim = [
      ## Upstream patches after the Qt6 transition that apply without problems & fix bugs

      # Fixes QList -> QSet conversion
      (fetchpatch {
        hash = "sha256-zlxD45JnbhIgdJxMmGxGMUBcQPcgzpu3s4bLX939jL0=";
        url = "https://github.com/qt/qtpim/commit/f337e281e28904741a3b1ac23d15c3a83ef2bbc9.patch";
      })
      # Fixes invalid syntax from a previous bad patch in tests
      (fetchpatch {
        hash = "sha256-mg93QF3hi50igw1/Ok7fEs9iCaN6co1+p2/5fQtxTmc=";
        url = "https://github.com/qt/qtpim/commit/2aefdd8bd28a4decf9ef8381f5b255f39f1ee90c.patch";
      })
      # Unit test account for QList index change
      (fetchpatch {
        hash = "sha256-u+cLl4lu6r2+j5GAiasqbB6/OZPz5A6GpSB33vd/VBg=";
        url = "https://github.com/qt/qtpim/commit/79b41af6a4117f5efb0298289e20c30b4d0b0b2e.patch";
      })
      # Remove invalid method overload which confuses the QML engine
      (fetchpatch {
        hash = "sha256-z8f8kLhC9CqBOfGPL8W9KJq7MwALAAicXfRkHiQEVJ4=";
        url = "https://github.com/qt/qtpim/commit/5679a6141c76ae7d64c3acc8a87b1adb048289e0.patch";
      })
      # Specify enum flag type properly in unit test
      (fetchpatch {
        hash = "sha256-SsYkxX6prxi8VRZr4az+wqawcRN8tR3UuIFswJL+3T4=";
        url = "https://github.com/qt/qtpim/commit/a43cc24e57db8d3c3939fa540d67da3294dcfc5c.patch";
      })
      # Update qHash methods to return size_t instead of uint
      (fetchpatch {
        hash = "sha256-rb8D8taaglhQikYSAPrtLvazgIw8Nga/a9+J21k8gIo=";
        url = "https://github.com/qt/qtpim/commit/9c698155d82fc2b68a87c59d0443c33f9085b117.patch";
      })
      # Mark virtual methods with override keyword
      (fetchpatch {
        hash = "sha256-tNPOEVpx1eqHx5T23ueW32KxMQ/SB+TBCJ4PZ6SA3LI=";
        url = "https://github.com/qt/qtpim/commit/f34cf2ff2b0f428d5b8a70763b29088075ebbd1c.patch";
      })
      # Fix calendardemo example
      (fetchpatch {
        hash = "sha256-RPRtGQ24NQYewnv6+IqYITpwD/XxuK68a1iKgFmKm3c=";
        url = "https://github.com/qt/qtpim/commit/a66590d473753bc49105d3132fb9e4150c92a14a.patch";
      })
      # Make the tests pass on big endian systems
      (fetchpatch {
        hash = "sha256-hogUXyPXjGE0q53PWOjiQbQ2YzOsvrJ7mo9djGIbjVQ=";
        url = "https://github.com/qt/qtpim/commit/7802f038ed1391078e27fa3f37d785a69314537b.patch";
      })
      # Fix some deprecated QChar constructor issues in unit tests
      (fetchpatch {
        hash = "sha256-yZ1qs8y5DSq8FDXRPyuSPRIzjEUTWAhpVide/b+xaLQ=";
        url = "https://github.com/qt/qtpim/commit/114615812dcf9398c957b0833e860befe15f840f.patch";
      })
      # Provide interface for accessing all extended metadata from collections
      (fetchpatch {
        hash = "sha256-asJNa8tcdtovVE579FjZg1CHeCmvRJ8otQeSrEdrXdQ=";
        url = "https://github.com/qt/qtpim/commit/5bdfb9127b3f6c9863def0578c7a8734a5156ea9.patch";
      })
      # Accessors should be const
      (fetchpatch {
        hash = "sha256-+YfPrKyOKnPkqFokwW/aDsEivg4TzdJwQpDdAtM+rQE=";
        url = "https://github.com/qt/qtpim/commit/a2bf7cdf05c264b5dd2560f799760b5508f154e4.patch";
      })
      # Enforce detail access constraints in contact operations by default
      (fetchpatch {
        hash = "sha256-vp/enerVecEXz4zyxQ66DG+fVVWxI4bYnLj92qaaqNk=";
        url = "https://github.com/qt/qtpim/commit/8765a35233aa21a932ee92bbbb92a5f8edd4dc68.patch";
      })
      # Fixes broken file generation, which breaks reverse dependencies that try to find one of its modules
      (fetchpatch {
        hash = "sha256-2dXhkZyxPvY2KQq2veerAlpXkpU5/FeArWRlm1aOcEY=";
        url = "https://github.com/qt/qtpim/commit/4b2bdce30bd0629c9dc0567af6eeaa1d038f3152.patch";
      })

      ## Patches that haven't been upstreamed

      # Fix tst_QContactManager::compareVariant_data test
      (fetchpatch {
        hash = "sha256-k/rO9QjwSlRChwFTZLkxDjZWqFkua4FNbaNf1bJKLxc=";
        url = "https://salsa.debian.org/qt-kde-team/qt/qtpim/-/raw/360682f88457b5ae7c92f32f574e51ccc5edbea0/debian/patches/1001_fix-qtdatetime-null-comparison.patch";
      })
      # Avoid crash while parsing vCards from different threads
      (fetchpatch {
        hash = "sha256-zhayAoWgcmKosEGVBy2k6a2e6BxyVwfGX18tBbzqEk8=";
        url = "https://salsa.debian.org/qt-kde-team/qt/qtpim/-/raw/360682f88457b5ae7c92f32f574e51ccc5edbea0/debian/patches/1002_Avoid-crash-while-parsing-vcards-from-different-threads.patch";
      })
      # Adapt to JSON parser behavior change in Qt 5.15
      (fetchpatch {
        hash = "sha256-qAIa48hmDd8vMH/ywqW+22vISKai76XnjgFuB+tQbIU=";
        url = "https://salsa.debian.org/qt-kde-team/qt/qtpim/-/raw/360682f88457b5ae7c92f32f574e51ccc5edbea0/debian/patches/1003_adapt_to_json_parser_change.patch";
      })
      # Fix version being 0.0.0
      (fetchpatch {
        hash = "sha256-6wg/eVu9J83yvIO428U1FX3otz58tAy6pCvp7fqOBKU=";
        url = "https://salsa.debian.org/qt-kde-team/qt/qtpim/-/raw/360682f88457b5ae7c92f32f574e51ccc5edbea0/debian/patches/2000_revert_module_version.patch";
      })
    ];

    qtscript = [
      ./qtscript.patch
      (fetchpatch {
        hash = "sha256-DUTXX20ClqGRYat8zk3/Facc1IyAw58qCXrbUaDLyiM=";
        name = "qtscript-loongarch64.patch";
        url = "https://gitlab.alpinelinux.org/alpine/aports/-/raw/2fa4f3b28affc29835fcca5c75431f19ff3754a3/community/qt5-qtscript/qtscript-loongarch64.patch";
      })
    ];

    qtserialport = [ ./qtserialport.patch ];

    qtsystems = [
      # Fix crash if no X11 display available
      (fetchpatch {
        hash = "sha256-/onla2nlUSySEgz2IYOYajx/LZkJzAKDyxwAZzy0Ivs=";
        url = "https://salsa.debian.org/qt-kde-team/qt/qtsystems/-/raw/1a4df40671d6f1bb0657a9dfdae4cd9bd48fcf21/debian/patches/1005_check_XOpenDisplay.patch";
      })

      # Enable building with udisks support
      (fetchpatch {
        hash = "sha256-B/z/+tai01RU/bAJSCp5a0/dGI8g36nwso8MiJv27YM=";
        url = "https://salsa.debian.org/qt-kde-team/qt/qtsystems/-/raw/a23fd92222c33479d7f3b59e48116def6b46894c/debian/patches/2001_build_with_udisk.patch";
      })
    ];

    qttools = [ ./qttools.patch ];
  };

  addPackages =
    self:
    let
      qtModuleWithStdenv =
        stdenv:
        callPackage ../qtModule.nix {
          inherit patches;
          # Use a variant of mkDerivation that does not include wrapQtApplications
          # to avoid cyclic dependencies between Qt modules.
          mkDerivation = (callPackage ../mkDerivation.nix { wrapQtAppsHook = null; }) stdenv.mkDerivation;
        };
      qtModule = qtModuleWithStdenv stdenv;

      callPackage = self.newScope {
        inherit
          qtCompatVersion
          qtModule
          srcs
          stdenv
          ;
      };
    in
    {

      inherit
        callPackage
        qtCompatVersion
        qtModule
        srcs
        ;

      env = callPackage ../qt-env.nix { };
      mkDerivation = callPackage ({ mkDerivationWith }: mkDerivationWith stdenv.mkDerivation) { };
      mkDerivationWith = callPackage ../mkDerivation.nix { };

      qmake = callPackage (
        { qtbase }:
        makeSetupHook {
          ${
            if stdenv.buildPlatform == stdenv.hostPlatform then
              "propagatedBuildInputs"
            else
              "depsTargetTargetPropagated"
          } =
            [ qtbase.dev ];

          name = "qmake-hook";

          substitutions = {
            inherit debug;
            fix_qmake_libtool = ../hooks/fix-qmake-libtool.sh;
          };

          meta.license = lib.licenses.mit;
        } ../hooks/qmake-hook.sh
      ) { };

      qt3d = callPackage ../modules/qt3d.nix { };

      qtbase = callPackage ../modules/qtbase.nix {
        inherit (srcs.qtbase) src version;
        inherit developerBuild decryptSslTraffic;
        patches = patches.qtbase;
        withGtk3 = !stdenv.hostPlatform.isDarwin;
      };

      qtcharts = callPackage ../modules/qtcharts.nix { };
      qtconnectivity = callPackage ../modules/qtconnectivity.nix { };
      qtdatavis3d = callPackage ../modules/qtdatavis3d.nix { };
      qtdeclarative = callPackage ../modules/qtdeclarative.nix { };
      qtdoc = callPackage ../modules/qtdoc.nix { };
      qtgamepad = callPackage ../modules/qtgamepad.nix { };
      qtgraphicaleffects = callPackage ../modules/qtgraphicaleffects.nix { };
      qtimageformats = callPackage ../modules/qtimageformats.nix { };
      qtlocation = callPackage ../modules/qtlocation.nix { };
      qtlottie = callPackage ../modules/qtlottie.nix { };
      qtmacextras = callPackage ../modules/qtmacextras.nix { };
      qtmultimedia = callPackage ../modules/qtmultimedia.nix { };
      qtnetworkauth = callPackage ../modules/qtnetworkauth.nix { };
      qtpim = callPackage ../modules/qtpim.nix { };
      qtpositioning = callPackage ../modules/qtpositioning.nix { };
      qtpurchasing = callPackage ../modules/qtpurchasing.nix { };
      qtquick1 = null;
      qtquick3d = callPackage ../modules/qtquick3d.nix { };
      qtquickcontrols = callPackage ../modules/qtquickcontrols.nix { };
      qtquickcontrols2 = callPackage ../modules/qtquickcontrols2.nix { };
      qtremoteobjects = callPackage ../modules/qtremoteobjects.nix { };
      qtscript = callPackage ../modules/qtscript.nix { };
      qtscxml = callPackage ../modules/qtscxml.nix { };
      qtsensors = callPackage ../modules/qtsensors.nix { };
      qtserialbus = callPackage ../modules/qtserialbus.nix { };
      qtserialport = callPackage ../modules/qtserialport.nix { };
      qtspeech = callPackage ../modules/qtspeech.nix { };
      qtsvg = callPackage ../modules/qtsvg.nix { };
      qtsystems = callPackage ../modules/qtsystems.nix { };
      qttools = callPackage ../modules/qttools.nix { };
      qttranslations = callPackage ../modules/qttranslations.nix { };
      qtvirtualkeyboard = callPackage ../modules/qtvirtualkeyboard.nix { };
      qtwayland = callPackage ../modules/qtwayland.nix { };
      qtwebchannel = callPackage ../modules/qtwebchannel.nix { };
      qtwebglplugin = callPackage ../modules/qtwebglplugin.nix { };
      qtwebsockets = callPackage ../modules/qtwebsockets.nix { };
      qtx11extras = callPackage ../modules/qtx11extras.nix { };
      qtxmlpatterns = callPackage ../modules/qtxmlpatterns.nix { };

      wrapQtAppsHook = callPackage (
        {
          makeBinaryWrapper,
          qtbase,
          qtwayland,
          wrapQtAppsHook,
        }:
        makeSetupHook {
          propagatedBuildInputs = [
            qtbase.dev
            makeBinaryWrapper
          ]
          ++ lib.optional stdenv.hostPlatform.isLinux qtwayland.dev;

          name = "wrap-qt5-apps-hook";

          passthru.tests = callPackages ../../qt-6/tests/wrap-qt-apps-hook.nix {
            inherit qtbase wrapQtAppsHook;
          };

          meta.license = lib.licenses.mit;
        } ../hooks/wrap-qt-apps-hook.sh
      ) { };
    }
    // lib.optionalAttrs config.allowAliases {
      full = throw "libsForQt5.full has been removed. Please use individual packages instead."; # Added 2025-10-18
    };

  baseScope = makeScopeWithSplicing' {
    f = addPackages;
    otherSplices = generateSplicesForMkScope "qt5";
  };

  bootstrapScope = baseScope.overrideScope (
    final: prev: {
      qtbase = prev.qtbase.override { qttranslations = null; };
      qtdeclarative = null;
    }
  );

  finalScope = baseScope.overrideScope (
    final: prev: {
      # qttranslations causes eval-time infinite recursion when
      # cross-compiling; disabled for now.
      qttranslations =
        if stdenv.buildPlatform == stdenv.hostPlatform then bootstrapScope.qttranslations else null;
    }
  );
in
finalScope
