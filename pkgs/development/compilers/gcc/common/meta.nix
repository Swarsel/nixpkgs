{
  lib,
  targetPrefix,
  version,
}:

let
  inherit (lib)
    licenses
    maintainers
    platforms
    teams
    versionOlder
    ;
in
{
  description = "GNU Compiler Collection, version ${version}";
  homepage = "https://gcc.gnu.org/";
  identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "gnu" version;
  license = licenses.gpl3Plus; # runtime support libraries are typically LGPLv3+

  longDescription = ''
    The GNU Compiler Collection includes compiler front ends for C, C++,
    Objective-C, Fortran, OpenMP for C/C++/Fortran, and Ada, as well as
    libraries for these languages (libstdc++, libgomp,...).

    GCC development is a part of the GNU Project, aiming to improve the
    compiler used in the GNU system including the GNU/Linux variant.
  '';

  mainProgram = "${targetPrefix}gcc";
  platforms = platforms.unix;

  teams = [
    teams.gcc
    teams.security-review
  ];
}
