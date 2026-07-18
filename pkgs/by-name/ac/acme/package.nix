{
  lib,
  stdenv,
  fetchsvn,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "acme";
  version = "0.97-unstable-2021-11-05";

  src = fetchsvn {
    url = "svn://svn.code.sf.net/p/acme-crossass/code-0/trunk";
    rev = "323";
    sha256 = "1dzvip90yf1wg0fhfghn96dwrhg289d06b624px9a2wwy3vp5ryg";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "= gcc" "?= gcc"
  '';

  makeFlags = [ "BINDIR=$(out)/bin" ];
  enableParallelBuilding = true;
  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Multi-platform cross assembler for 6502/6510/65816 CPUs";
    homepage = "https://sourceforge.net/projects/acme-crossass/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.all;
    mainProgram = "acme";
  };
})
