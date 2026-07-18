{
  lib,
  bctoolbox,
  mkLinphoneDerivation,
}:
mkLinphoneDerivation {
  pname = "ortp";
  buildInputs = [ bctoolbox ];
  env.NIX_CFLAGS_COMPILE = "-Wno-error=stringop-truncation";

  meta = {
    description = "Real-Time Transport Protocol (RFC3550) stack. Part of the Linphone project";
    license = lib.licenses.agpl3Plus;
    mainProgram = "ortp_tester";
  };
}
