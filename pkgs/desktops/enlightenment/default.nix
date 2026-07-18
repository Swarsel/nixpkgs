{ lib, pkgs }:

lib.makeScope pkgs.newScope (
  self: with self; {

    #### APPLICATIONS
    econnman = callPackage ./econnman { };
    ecrire = callPackage ./ecrire { };
    #### CORE EFL
    efl = callPackage ./efl { };
    #### WINDOW MANAGER
    enlightenment = callPackage ./enlightenment { };
    ephoto = callPackage ./ephoto { };
    evisum = callPackage ./evisum { };
    rage = callPackage ./rage { };
    terminology = callPackage ./terminology { };

  }
)
