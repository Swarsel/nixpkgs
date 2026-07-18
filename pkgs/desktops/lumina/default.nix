{ libsForQt5, pkgs }:

let
  packages =
    self: with self; {

      corePackages = [
        lumina
        lumina-calculator
        lumina-pdf
      ];

      lumina = callPackage ./lumina { };
      lumina-calculator = callPackage ./lumina-calculator { };
      lumina-pdf = callPackage ./lumina-pdf { };

      preRequisitePackages = [
        pkgs.fluxbox
        pkgs.libsForQt5.kwindowsystem
        pkgs.numlockx
        pkgs.qt5.qtsvg
        pkgs.xscreensaver
      ];

    };

in
pkgs.lib.makeScope libsForQt5.newScope packages
