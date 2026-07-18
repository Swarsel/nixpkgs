{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gopkgs";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "uudashr";
    repo = "gopkgs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ll5fhwzzCNL0UtMLNSGOY6Yyy0EqI8OZ1iqWad4KU8k=";
  };

  vendorHash = "sha256-WVikDxf79nEahKRn4Gw7Pv8AULQXW+RXGoA3ihBhmt8=";
  doCheck = false;
  subPackages = [ "cmd/gopkgs" ];

  meta = {
    description = "Tool to get list available Go packages";
    homepage = "https://github.com/uudashr/gopkgs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vdemeester ];
    mainProgram = "gopkgs";
  };
})
