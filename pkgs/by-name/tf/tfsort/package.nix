{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "tfsort";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "AlexNabokikh";
    repo = "tfsort";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PQ7DROZf67pa6VeSsACgOhXz0jCmh48yiVAxMMbyIII=";
  };

  vendorHash = "sha256-SebYucVQTbIr3kCaCVejw3FEaw9wi2fBVT55yuZRn48=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
    "-X main.commit=${finalAttrs.version}"
    "-X main.date=1970-01-01"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Utility to sort Terraform variables, outputs, locals and terraform blocks";
    homepage = "https://github.com/AlexNabokikh/tfsort";
    changelog = "https://github.com/AlexNabokikh/tfsort/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = [
      lib.maintainers.alexnabokikh
    ];

    mainProgram = "tfsort";
  };
})
