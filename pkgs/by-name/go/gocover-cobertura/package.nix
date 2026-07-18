{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gocover-cobertura";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "boumenot";
    repo = "gocover-cobertura";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-7NrdoAUwbN6S19elYkYEiDbxIFVOaAnT7CbYZej/cfs=";
  };

  vendorHash = null;
  deleteVendor = true;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Simple helper tool for generating XML output in Cobertura format for CIs like Jenkins and others from go tool cover output";
    homepage = "https://github.com/boumenot/gocover-cobertura";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      gabyx
      hmajid2301
    ];

    mainProgram = "gocover-cobertura";
  };
})
