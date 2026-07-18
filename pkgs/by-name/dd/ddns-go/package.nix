{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "ddns-go";
  version = "6.17.1";

  src = fetchFromGitHub {
    owner = "jeessy2";
    repo = "ddns-go";
    rev = "v${finalAttrs.version}";
    hash = "sha256-F5QErTVE4wjNMyJHSQN3MFTiTLdgy5ADf+UUZ8acF14=";
  };

  vendorHash = "sha256-3jIWxjjPeEj02OQkXLvcqLJH+PjuEtL2zhfUAOtQJio=";
  # network required
  doCheck = false;

  ldflags = [
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Simple and easy to use DDNS";
    homepage = "https://github.com/jeessy2/ddns-go";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ oluceps ];
    mainProgram = "ddns-go";
  };
})
