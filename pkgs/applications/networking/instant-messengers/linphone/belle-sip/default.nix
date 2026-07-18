{
  lib,
  stdenv,
  bctoolbox,
  belr,
  libantlr3c,
  mkLinphoneDerivation,
  python3,
  zlib,
}:
mkLinphoneDerivation {
  pname = "belle-sip";

  nativeBuildInputs = [
    python3
  ];

  propagatedBuildInputs = [
    libantlr3c
    bctoolbox
    belr
    zlib
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    [
      "-Wno-error=cast-function-type"
      "-Wno-error=deprecated-declarations"
      "-Wno-error=format-truncation"
      "-Wno-error=stringop-overflow"
    ]
    ++ lib.optionals (stdenv.cc.isGNU && lib.versionAtLeast stdenv.cc.version "12") [
      # Needed with GCC 12 but problematic with some old GCCs and probably clang
      "-Wno-error=use-after-free"
    ]
  );

  meta = {
    description = "Modern library implementing SIP (RFC 3261) transport, transaction and dialog layers. Part of the Linphone project";
    license = lib.licenses.gpl3Only;
    mainProgram = "belle_sip_tester";
  };
}
