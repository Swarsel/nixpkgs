{ callPackage }:

{
  inherit callPackage;
  carddav = callPackage ./carddav { };
  contextmenu = callPackage ./contextmenu { };
  custom_from = callPackage ./custom_from { };
  persistent_login = callPackage ./persistent_login { };
  roundcubePlugin = callPackage ./roundcube-plugin.nix { };
  thunderbird_labels = callPackage ./thunderbird_labels { };
}
