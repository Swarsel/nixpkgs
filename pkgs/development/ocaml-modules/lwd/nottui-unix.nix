{
  lib,
  buildDunePackage,
  lwd,
  nottui,
}:

buildDunePackage {
  inherit (lwd) version src;
  pname = "nottui-unix";

  propagatedBuildInputs = [
    lwd
    nottui
  ];

  meta = {
    description = "UI toolkit for the UNIX terminal built on top of Notty and Lwd";
    homepage = "https://github.com/let-def/lwd";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
