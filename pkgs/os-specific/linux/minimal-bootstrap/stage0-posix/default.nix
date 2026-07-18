{
  lib,
  newScope,
}:

lib.makeScope newScope (
  self: with self; {
    inherit (callPackage ./platforms.nix { })
      platforms
      stage0Arch
      m2libcArch
      m2libcOS
      baseAddress
      ;

    inherit (self.callPackage ./bootstrap-sources.nix { }) version minimal-bootstrap-sources;
    inherit (self.hex0) hex0-seed;

    inherit (self.mescc-tools-boot)
      blood-elf-0
      hex2
      kaem-unwrapped
      M1
      M2
      ;

    src = minimal-bootstrap-sources;
    hex0 = callPackage ./hex0.nix { };
    kaem = callPackage ./kaem { };
    kaem-minimal = callPackage ./kaem/minimal.nix { };
    m2libc = src + "/M2libc";
    mescc-tools = callPackage ./mescc-tools { };
    mescc-tools-boot = callPackage ./mescc-tools-boot.nix { };
    mescc-tools-extra = callPackage ./mescc-tools-extra { };
  }
)
