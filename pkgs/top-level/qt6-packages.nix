# Qt packages set.
#
# Attributes in this file are packages requiring Qt and will be made available
# for every Qt version. Qt applications are called from `all-packages.nix` via
# this file.

{
  lib,
  stdenv,
  __splicedPackages,
  config,
  generateSplicesForMkScope,
  kdePackages,
  makeScopeWithSplicing',
  pkgsHostTarget,
}:

let
  pkgs = __splicedPackages;
  # qt6 set should not be pre-spliced to prevent spliced packages being a part of an unspliced set
  # 'pkgsCross.aarch64-multiplatform.pkgsBuildTarget.targetPackages.qt6Packages.qtbase' should not have a `__spliced` but if qt6 is pre-spliced then it will have one.
  # pkgsHostTarget == pkgs
  qt6 = pkgsHostTarget.qt6;
in

makeScopeWithSplicing' {
  f = (
    self:
    let
      inherit (self) callPackage;
      noExtraAttrs =
        set:
        lib.attrsets.removeAttrs set [
          "extend"
          "override"
          "overrideScope"
          "overrideDerivation"
        ];
    in
    (noExtraAttrs qt6)
    // {

      # LIBRARIES
      accounts-qml-module = callPackage ../development/libraries/accounts-qml-module { };
      accounts-qt = callPackage ../development/libraries/accounts-qt { };
      appstream-qt = callPackage ../development/libraries/appstream/qt.nix { };
      drumstick = callPackage ../development/libraries/drumstick { };
      fcitx5-chinese-addons = callPackage ../tools/inputmethods/fcitx5/fcitx5-chinese-addons.nix { };
      fcitx5-configtool = kdePackages.callPackage ../tools/inputmethods/fcitx5/fcitx5-configtool.nix { };
      fcitx5-qt = callPackage ../tools/inputmethods/fcitx5/fcitx5-qt.nix { };
      fcitx5-skk-qt = pkgs.fcitx5-skk.override { enableQt = true; };
      fcitx5-unikey = callPackage ../tools/inputmethods/fcitx5/fcitx5-unikey.nix { };
      fcitx5-with-addons = callPackage ../tools/inputmethods/fcitx5/with-addons.nix { };
      futuresql = callPackage ../development/libraries/futuresql { };
      kcolorpicker = callPackage ../development/libraries/kcolorpicker { };
      kdsoap = callPackage ../development/libraries/kdsoap { };
      kimageannotator = callPackage ../development/libraries/kimageannotator { };
      kquickimageedit = callPackage ../development/libraries/kquickimageedit { };
      ktactilefeedback = kdePackages.callPackage ../development/libraries/ktactilefeedback { };
      libiodata = callPackage ../development/libraries/libiodata { };
      libqaccessibilityclient = callPackage ../development/libraries/libqaccessibilityclient { };
      libqglviewer = callPackage ../development/libraries/libqglviewer { };

      libqtdbusmock = callPackage ../development/libraries/libqtdbusmock {
        inherit (pkgs.lomiri-qt6) cmake-extras;
      };

      libqtdbustest = callPackage ../development/libraries/libqtdbustest {
        inherit (pkgs.lomiri-qt6) cmake-extras;
      };

      libqtpas = callPackage ../development/compilers/fpc/libqtpas.nix { };
      libquotient = callPackage ../development/libraries/libquotient { };
      maplibre-native-qt = callPackage ../development/libraries/maplibre-native-qt { };
      mlt = callPackage ../by-name/ml/mlt/package.nix { };
      packagekit-qt = callPackage ../tools/package-management/packagekit/qt.nix { };

      poppler = callPackage ../development/libraries/poppler {
        lcms = pkgs.lcms2;
        qt6Support = true;
        suffix = "qt6";
      };

      pyotherside = callPackage ../development/libraries/pyotherside { };
      qca = callPackage ../development/libraries/qca { };
      qcoro = callPackage ../development/libraries/qcoro { };
      qcustomplot = callPackage ../development/libraries/qcustomplot { };
      qgpgme = callPackage ../development/libraries/qgpgme { };
      qhotkey = callPackage ../development/libraries/qhotkey { };

      qmenumodel = callPackage ../development/libraries/qmenumodel {
        inherit (pkgs.lomiri-qt6) cmake-extras;
      };

      qmlbox2d = callPackage ../development/libraries/qmlbox2d { };
      qodeassist-plugin = callPackage ../development/libraries/qodeassist-plugin { };
      qscintilla = callPackage ../development/libraries/qscintilla { };
      qt-color-widgets = callPackage ../development/libraries/qt-color-widgets { };
      qt-jdenticon = callPackage ../development/libraries/qt-jdenticon { };
      qt6ct = callPackage ../tools/misc/qt6ct { };
      qt6gtk2 = callPackage ../tools/misc/qt6gtk2 { };
      qtforkawesome = callPackage ../development/libraries/qtforkawesome { };
      qtkeychain = callPackage ../development/libraries/qtkeychain { };
      qtpbfimageplugin = callPackage ../development/libraries/qtpbfimageplugin { };
      qtspell = callPackage ../development/libraries/qtspell { };
      qtstyleplugin-kvantum = kdePackages.callPackage ../development/libraries/qtstyleplugin-kvantum { };
      qtutilities = callPackage ../development/libraries/qtutilities { };
      quazip = callPackage ../development/libraries/quazip { };
      qwt = callPackage ../development/libraries/qwt/default.nix { };
      qxlsx = callPackage ../development/libraries/qxlsx { };
      qzxing = callPackage ../development/libraries/qzxing { };

      sailfish-access-control-plugin =
        callPackage ../development/libraries/sailfish-access-control-plugin
          { };

      sddm = callPackage ../applications/display-managers/sddm { };
      sddm-unwrapped = callPackage ../applications/display-managers/sddm/unwrapped.nix { };

      sierra-breeze-enhanced =
        kdePackages.callPackage ../data/themes/kwin-decorations/sierra-breeze-enhanced
          { };

      signond = callPackage ../development/libraries/signond { };
      timed = callPackage ../applications/system/timed { };
      wayqt = callPackage ../development/libraries/wayqt { };
    }
    // lib.optionalAttrs config.allowAliases {
      qwlroots = throw ''
        'qt6Packages.qwlroots' has been removed because it has been merged into treeland upstream.
        The upstream no longer provides it as a standalone development library.
      ''; # Added 2025-02-07

      waylib = throw ''
        'qt6Packages.waylib' has been removed because it has been merged into treeland upstream.
        The upstream no longer provides it as a standalone development library.
      ''; # Added 2025-02-07
    }
  );

  otherSplices = generateSplicesForMkScope "qt6Packages";
}
