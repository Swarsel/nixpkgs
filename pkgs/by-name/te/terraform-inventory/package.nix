{
  lib,
  fetchFromGitHub,
  buildGoModule,
  terraform-inventory,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "terraform-inventory";
  version = "0.10";

  src = fetchFromGitHub {
    owner = "adammck";
    repo = "terraform-inventory";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-gkSDxcBoYmCBzkO8y1WKcRtZdfl8w5qVix0zbyb4Myo=";
  };

  vendorHash = "sha256-pj9XLzaGU1PuNnpTL/7XaKJZUymX+i8hFMroZtHIqTc=";
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.build_version=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    package = terraform-inventory;
  };

  meta = {
    description = "Terraform state to ansible inventory adapter";
    homepage = "https://github.com/adammck/terraform-inventory";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ htr ];
    mainProgram = "terraform-inventory";
  };
})
