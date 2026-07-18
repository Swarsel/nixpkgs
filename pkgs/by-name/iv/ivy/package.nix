{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "ivy";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "robpike";
    repo = "ivy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-O+CQUS2EYPnRf8AbL2arhF7m5vhPUnDFXJsYst9/Eqg=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "." ];

  meta = {
    description = "APL-like calculator";
    homepage = "https://github.com/robpike/ivy";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ smasher164 ];
    mainProgram = "ivy";
  };
})
