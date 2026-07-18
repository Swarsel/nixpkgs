{
  lib,
  buildDunePackage,
  lwd,
  notty-community,
}:

buildDunePackage {
  inherit (lwd) version src;
  pname = "nottui";

  propagatedBuildInputs = [
    lwd
    notty-community
  ];

  meta = {
    description = "UI toolkit for the terminal built on top of Notty and Lwd";
    homepage = "https://github.com/let-def/lwd";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.alizter ];
  };
}
