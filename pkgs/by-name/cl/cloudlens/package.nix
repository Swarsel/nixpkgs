{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  buildGoModule,
  xclip,
}:

buildGoModule (finalAttrs: {
  pname = "cloudlens";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "one2nc";
    repo = "cloudlens";
    rev = "v${finalAttrs.version}";
    hash = "sha256-b0i9xaIm42RKWzzZdSAmapbmZDmTpCa4IxVsM9eSMqM=";
  };

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;
  buildInputs = [ xclip ];
  vendorHash = "sha256-7TxtM0O3wlfq0PF5FGn4i+Ph7dWRIcyLjFgnnKITLGM=";
  #Some tests require internet access
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/one2nc/cloudlens/cmd.version=v${finalAttrs.version}"
    "-X=github.com/one2nc/cloudlens/cmd.commit=${finalAttrs.src.rev}"
    "-X=github.com/one2nc/cloudlens/cmd.date=1970-01-01T00:00:00Z"
  ];

  meta = {
    description = "K9s like CLI for AWS and GCP";
    homepage = "https://github.com/one2nc/cloudlens";
    license = lib.licenses.apsl20;
    maintainers = with lib.maintainers; [ ByteSudoer ];
    mainProgram = "cloudlens";
  };
})
