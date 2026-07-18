{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "tfautomv";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "busser";
    repo = "tfautomv";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/bwCP8HViGQr3kLVQxHOg7bhNwe2D+wif96IdcHD4nk=";
  };

  vendorHash = "sha256-7BjytBX52xB8ThneBoSV6sEVcknQMs776D3nY7ckrBM=";
  # checks require unfree programs like terraform/terragrunt
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "When refactoring a Terraform codebase, you often need to write moved blocks. This can be tedious. Let tfautomv do it for you";
    homepage = "https://github.com/busser/tfautomv";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ qjoly ];
    mainProgram = "tfautomv";
  };
})
