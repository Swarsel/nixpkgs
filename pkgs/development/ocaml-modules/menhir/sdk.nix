{
  lib,
  buildDunePackage,
  menhirLib,
}:

buildDunePackage {
  inherit (menhirLib) version src;
  pname = "menhirSdk";

  meta = menhirLib.meta // {
    description = "Compile-time library for auxiliary tools related to Menhir";
    license = with lib.licenses; [ gpl2Only ];
  };
}
