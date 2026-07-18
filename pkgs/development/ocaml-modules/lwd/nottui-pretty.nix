{
  lib,
  buildDunePackage,
  lwd,
  nottui,
}:

buildDunePackage {
  inherit (lwd) version src;
  pname = "nottui-pretty";
  propagatedBuildInputs = [ nottui ];

  meta = {
    description = "Pretty-printer based on PPrint rendering UIs";
    homepage = "https://github.com/let-def/lwd";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.alizter ];
  };
}
