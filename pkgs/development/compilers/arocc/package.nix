{
  lib,
  stdenv,
  overrideCC,
  src,
  version,
  wrapCCWith,
  zig,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  pname = "arocc";
  nativeBuildInputs = [ zig ];

  passthru = {
    inherit zig;
    isArocc = true;
    stdenv = overrideCC stdenv finalAttrs.passthru.wrapped;
    wrapped = wrapCCWith { cc = finalAttrs.finalPackage; };
  };

  meta = {
    description = "C compiler written in Zig";
    homepage = "http://aro.vexu.eu/";

    license = with lib.licenses; [
      mit
      unicode-30
    ];

    maintainers = with lib.maintainers; [ RossComputerGuy ];
    mainProgram = "arocc";
  };
})
