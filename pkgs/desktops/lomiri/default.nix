{
  lib,
  ayatana-indicator-datetime,
  config,
  libsForQt5,
  pkgs,
  qt6Packages,
  useQt6 ? false,
}:

let
  qtPackages = if useQt6 then qt6Packages else libsForQt5;
  packages =
    self:
    let
      inherit (self) callPackage;
    in
    {
      #### Services
      biometryd = callPackage ./services/biometryd { };
      #### Development tools / libraries
      cmake-extras = callPackage ./development/cmake-extras { };
      deviceinfo = callPackage ./development/deviceinfo { };
      geonames = callPackage ./development/geonames { };
      gmenuharness = callPackage ./development/gmenuharness { };
      gsettings-qt = callPackage ./development/gsettings-qt { };

      #### QML / QML-related
      lomiri-action-api = callPackage ./qml/lomiri-action-api {
        # The dependency target "qmldoc" of target "doc" does not exist.
        withDocumentation = !useQt6;
      };

      lomiri-api = callPackage ./development/lomiri-api { };
      lomiri-app-launch = callPackage ./development/lomiri-app-launch { };

      lomiri-content-hub = callPackage ./services/lomiri-content-hub {
        # Check for working qdoc: not found
        withDocumentation = !useQt6;
      };

      lomiri-download-manager = callPackage ./services/lomiri-download-manager {
        # Check for working qdoc: not found
        withDocumentation = !useQt6;
      };

      lomiri-indicator-network = callPackage ./services/lomiri-indicator-network { };
      lomiri-notifications = callPackage ./qml/lomiri-notifications { };
      lomiri-push-qml = callPackage ./qml/lomiri-push-qml { };
      #### Data
      lomiri-schemas = callPackage ./data/lomiri-schemas { };
      lomiri-sounds = callPackage ./data/lomiri-sounds { };
      lomiri-thumbnailer = callPackage ./services/lomiri-thumbnailer { };
      lomiri-ui-extras = callPackage ./qml/lomiri-ui-extras { };
      lomiri-ui-toolkit = callPackage ./qml/lomiri-ui-toolkit { };
      lomiri-url-dispatcher = callPackage ./services/lomiri-url-dispatcher { };
      lomiri-wallpapers = callPackage ./data/lomiri-wallpapers { };
      mediascanner2 = callPackage ./services/mediascanner2 { };
      qqc2-suru-style = callPackage ./qml/qqc2-suru-style { };
      suru-icon-theme = callPackage ./data/suru-icon-theme { };
    }
    // lib.optionalAttrs useQt6 {
      #### Core Apps
      morph-browser = callPackage ./applications/morph-browser {
        # get_target_property() called with non-existent target "Qt6::qdoc".
        withDocumentation = !useQt6;
      };
    }
    // lib.optionalAttrs (!useQt6) {
      #### Services
      hfd-service = callPackage ./services/hfd-service { };
      #### Development tools / libraries
      libusermetrics = callPackage ./development/libusermetrics { };
      #### Core Apps
      lomiri = callPackage ./applications/lomiri { };
      lomiri-calculator-app = callPackage ./applications/lomiri-calculator-app { };
      lomiri-calendar-app = callPackage ./applications/lomiri-calendar-app { };
      lomiri-camera-app = callPackage ./applications/lomiri-camera-app { };
      lomiri-clock-app = callPackage ./applications/lomiri-clock-app { };
      lomiri-docviewer-app = callPackage ./applications/lomiri-docviewer-app { };
      lomiri-filemanager-app = callPackage ./applications/lomiri-filemanager-app { };
      lomiri-gallery-app = callPackage ./applications/lomiri-gallery-app { };
      lomiri-history-service = callPackage ./services/lomiri-history-service { };
      lomiri-indicator-datetime = ayatana-indicator-datetime.override { enableLomiriFeatures = true; };
      lomiri-mediaplayer-app = callPackage ./applications/lomiri-mediaplayer-app { };
      lomiri-music-app = callPackage ./applications/lomiri-music-app { };
      lomiri-polkit-agent = callPackage ./services/lomiri-polkit-agent { };
      #### Data
      lomiri-session = callPackage ./data/lomiri-session { };
      #### QML / QML-related
      lomiri-settings-components = callPackage ./qml/lomiri-settings-components { };
      lomiri-system-settings = callPackage ./applications/lomiri-system-settings/wrapper.nix { };
      lomiri-system-settings-unwrapped = callPackage ./applications/lomiri-system-settings { };
      lomiri-telephony-service = callPackage ./services/lomiri-telephony-service { };
      lomiri-terminal-app = callPackage ./applications/lomiri-terminal-app { };
      qtmir = callPackage ./development/qtmir { };
      teleports = callPackage ./applications/teleports { };
      trust-store = callPackage ./development/trust-store { };
      u1db-qt = callPackage ./development/u1db-qt { };
    };
in
lib.makeScope qtPackages.newScope packages
// lib.optionalAttrs (config.allowAliases && !useQt6) {
  content-hub = lib.warnOnInstantiate "`content-hub` was renamed to `lomiri-content-hub`." pkgs.lomiri.lomiri-content-hub; # Added on 2024-09-11
  history-service = lib.warnOnInstantiate "`history-service` was renamed to `lomiri-history-service`." pkgs.lomiri.lomiri-history-service; # Added on 2024-11-11
  lomiri-system-settings-security-privacy = lib.warnOnInstantiate "`lomiri-system-settings-security-privacy` upstream was merged into `lomiri-system-settings`. Please use `pkgs.lomiri.lomiri-system-settings-unwrapped` if you need to directly access the plugins that belonged to this project." pkgs.lomiri.lomiri-system-settings-unwrapped; # Added on 2024-08-08
  morph-browser = throw "`lomiri.morph-browser` has been removed because it relied on the known-vulnerable `libsForQt5.qtwebengine`. Please use `lomiri-qt6.morph-browser` instead."; # Added on 2026-03-31
  telephony-service = lib.warnOnInstantiate "`telephony-service` was renamed to `lomiri-telephony-service`." pkgs.lomiri.lomiri-telephony-service; # Adder on 2025-01-15
}
