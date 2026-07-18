{
  lib,
  byacc,
  flex,
  libutil,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "etc"
    "man"
    "debug"
  ];

  postPatch = ''
    substituteInPlace $BSDSRCDIR/sbin/devd/Makefile --replace-fail /etc $etc/etc
  '';

  buildInputs = [
    libutil
  ];

  postInstall = ''
    make $makeFlags installconfig
  '';

  MK_ACPI = "yes";
  MK_AUTOFS = "yes";
  MK_BLUETOOTH = "yes";
  MK_HYPERV = "yes";
  MK_SOUND = "yes";
  MK_TESTS = "no";
  MK_USB = "yes";
  MK_ZFS = "yes";

  NIX_CFLAGS_COMPILE = [
    "-Wno-c++20-extensions"
    "-Wno-nullability-completeness"
  ];

  clangFixup = false;

  extraNativeBuildInputs = [
    flex
    byacc
  ];

  path = "sbin/devd";
  meta.mainProgram = "devd";
  meta.platforms = lib.platforms.freebsd;
}
