{
  lib,
  stdenv,
  fetchurl,
  apple-sdk_15,
  buildPackages,
  callPackages,
  config,
  darwin,
  darwinMinVersionHook,
  fetchpatch2,
  generateSplicesForMkScope,
  gst_all_1,
  libglvnd,
  makeScopeWithSplicing',
  makeSetupHook,
  makeWrapper,
  newScope,
  python3,
  runCommand,
}:

let
  srcs = import ./srcs.nix {
    inherit fetchurl;
    mirror = "mirror://qt";
  };

  addPackages =
    self:
    let
      callPackage = self.newScope {
        inherit (self) qtModule;
        inherit srcs python3 stdenv;
      };

      # Per <https://doc.qt.io/qt-6/macos.html#supported-versions>.
      # This should reflect the highest “Build Environment” and the
      # lowest “Target Platform”.
      darwinVersionInputs = [
        apple-sdk_15
        (darwinMinVersionHook "12.0")
      ];

      onlyPluginsAndQml =
        drv:
        let
          drv' = drv.__spliced.targetTarget or drv;
          inherit (self.qtbase) qtPluginPrefix qtQmlPrefix;
        in
        (runCommand "${drv'.name}-only-plugins-qml" { } ''
          mkdir -p $(dirname "$out/${qtPluginPrefix}")
          test -d "${drv'}/${qtPluginPrefix}" && ln -s "${drv'}/${qtPluginPrefix}" "$out/${qtPluginPrefix}" || true
          test -d "${drv'}/${qtQmlPrefix}" && ln -s "${drv'}/${qtQmlPrefix}" "$out/${qtQmlPrefix}" || true
        '');
    in
    {

      inherit callPackage srcs darwinVersionInputs;
      env = callPackage ./qt-env.nix { };

      qmake = callPackage (
        { qtbase }:
        makeSetupHook {
          propagatedBuildInputs = [ qtbase.dev ];
          name = "qmake6-hook";

          substitutions = {
            fix_qmake_libtool = ./hooks/fix-qmake-libtool.sh;
          };

          meta.license = lib.licenses.mit;
        } ./hooks/qmake-hook.sh
      ) { };

      qt3d = callPackage ./modules/qt3d.nix { };
      qt5compat = callPackage ./modules/qt5compat.nix { };

      qtModule = callPackage ./qtModule.nix {
        inherit darwinVersionInputs;
      };

      qtbase = callPackage ./modules/qtbase {
        inherit darwinVersionInputs;
        inherit (srcs.qtbase) src version;
        withGtk3 = !stdenv.hostPlatform.isMinGW;
      };

      qtcharts = callPackage ./modules/qtcharts.nix { };
      qtconnectivity = callPackage ./modules/qtconnectivity.nix { };
      qtdatavis3d = callPackage ./modules/qtdatavis3d.nix { };
      qtdeclarative = callPackage ./modules/qtdeclarative { };
      qtdoc = callPackage ./modules/qtdoc.nix { };
      qtgraphs = callPackage ./modules/qtgraphs.nix { };
      qtgrpc = callPackage ./modules/qtgrpc.nix { };
      qthttpserver = callPackage ./modules/qthttpserver.nix { };
      qtimageformats = callPackage ./modules/qtimageformats.nix { };
      qtlanguageserver = callPackage ./modules/qtlanguageserver.nix { };
      qtlocation = callPackage ./modules/qtlocation.nix { };
      qtlottie = callPackage ./modules/qtlottie.nix { };
      qtmqtt = callPackage ./modules/qtmqtt.nix { };

      qtmultimedia = callPackage ./modules/qtmultimedia {
        inherit (gst_all_1)
          gstreamer
          gst-plugins-bad
          gst-plugins-base
          gst-plugins-good
          gst-libav
          ;
      };

      qtnetworkauth = callPackage ./modules/qtnetworkauth.nix { };
      qtpositioning = callPackage ./modules/qtpositioning.nix { };
      qtquick3d = callPackage ./modules/qtquick3d.nix { };
      qtquick3dphysics = callPackage ./modules/qtquick3dphysics.nix { };
      qtquickeffectmaker = callPackage ./modules/qtquickeffectmaker.nix { };
      qtquicktimeline = callPackage ./modules/qtquicktimeline.nix { };
      qtremoteobjects = callPackage ./modules/qtremoteobjects.nix { };
      qtscxml = callPackage ./modules/qtscxml.nix { };
      qtsensors = callPackage ./modules/qtsensors.nix { };
      qtserialbus = callPackage ./modules/qtserialbus.nix { };
      qtserialport = callPackage ./modules/qtserialport.nix { };
      qtshadertools = callPackage ./modules/qtshadertools.nix { };
      qtspeech = callPackage ./modules/qtspeech.nix { };
      qtsvg = callPackage ./modules/qtsvg.nix { };
      qttools = callPackage ./modules/qttools { };

      qttranslations = callPackage ./modules/qttranslations.nix {
        qttools = self.qttools.override {
          qtbase = self.qtbase.override { qttranslations = null; };
          qtdeclarative = null;
        };
      };

      qtvirtualkeyboard = callPackage ./modules/qtvirtualkeyboard.nix { };
      qtwayland = callPackage ./modules/qtwayland.nix { };
      qtwebchannel = callPackage ./modules/qtwebchannel.nix { };

      qtwebengine = callPackage ./modules/qtwebengine {
        inherit (darwin) bootstrap_cmds;
      };

      qtwebsockets = callPackage ./modules/qtwebsockets.nix { };
      qtwebview = callPackage ./modules/qtwebview.nix { };

      wrapQtAppsHook = callPackage (
        {
          makeBinaryWrapper,
          qtbase,
          qtwayland,
          wrapQtAppsHook,
        }:
        makeSetupHook {
          propagatedBuildInputs = [ makeBinaryWrapper ];

          depsTargetTargetPropagated = [
            (onlyPluginsAndQml qtbase)
          ];

          name = "wrap-qt6-apps-hook";

          passthru.tests = callPackages ./tests/wrap-qt-apps-hook.nix {
            inherit qtbase wrapQtAppsHook;
          };

          meta.license = lib.licenses.mit;
        } ./hooks/wrap-qt-apps-hook.sh
      ) { };
    }
    // lib.optionalAttrs config.allowAliases {
      full = throw "qt6.full has been removed. Please use individual packages instead."; # Added 2025-10-21
      wrapQtAppsNoGuiHook = lib.warn "wrapQtAppsNoGuiHook is deprecated, use wrapQtAppsHook instead" self.wrapQtAppsHook;
    };

  baseScope = makeScopeWithSplicing' {
    f = addPackages;
    otherSplices = generateSplicesForMkScope "qt6";
  };
in
baseScope
