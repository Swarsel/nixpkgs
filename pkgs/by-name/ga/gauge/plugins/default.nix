{ lib, pkgs }:
lib.makeScope pkgs.newScope (
  final:
  let
    inherit (final) callPackage;
  in
  {
    dotnet = callPackage ./dotnet { };
    go = callPackage ./go { };
    html-report = callPackage ./html-report { };
    java = callPackage ./java { };
    js = callPackage ./js { };
    makeGaugePlugin = callPackage ./make-gauge-plugin.nix { };
    ruby = callPackage ./ruby { };
    screenshot = callPackage ./screenshot { };
    testGaugePlugins = callPackage ./test-gauge-plugins.nix { };
    xml-report = callPackage ./xml-report { };
  }
)
