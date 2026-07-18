{
  lib,
  buildDunePackage,
  lwd,
  lwt,
  nottui,
}:

buildDunePackage {
  inherit (lwd) version src;
  pname = "nottui-lwt";

  propagatedBuildInputs = [
    lwt
    nottui
  ];

  meta = {
    description = "Run Nottui UIs in Lwt";
    homepage = "https://github.com/let-def/lwd";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.alizter ];
  };
}
