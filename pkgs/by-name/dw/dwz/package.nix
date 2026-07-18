{
  lib,
  stdenv,
  fetchurl,
  dejagnu,
  elfutils,
  gdb,
  xxhash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dwz";
  version = "0.16";

  src = fetchurl {
    url = "https://www.sourceware.org/ftp/dwz/releases/dwz-${finalAttrs.version}.tar.gz";
    hash = "sha256-R1hT4bSebtjMLQqQnHpPwcxXHrzPxmJ4/UM0Lb4n1Q4=";
  };

  postPatch = ''
    patchShebangs --build testsuite
  '';

  strictDeps = true;
  nativeBuildInputs = [ elfutils ];

  buildInputs = [
    xxhash
    elfutils
  ];

  makeFlags = [ "prefix=${placeholder "out"}" ];
  doCheck = true;

  nativeCheckInputs = [
    dejagnu
    gdb
  ];

  meta = {
    description = "DWARF optimization and duplicate removal tool";
    homepage = "https://sourceware.org/dwz/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ jbcrail ];
    platforms = [ lib.systems.inspect.patterns.isElf ];
    mainProgram = "dwz";
  };
})
