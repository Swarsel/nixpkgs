{
  lib,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  ejson2env,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "ejson2env";
  version = "2.0.8";

  src = fetchFromGitHub {
    owner = "Shopify";
    repo = "ejson2env";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-0DKKdu1b/gjwtKycdXrV3hzAeGmvK41MlZbltcEzj/g=";
  };

  vendorHash = "sha256-UskdGQbLR4W7ucC0foMWim8o9BqyE5o0Nza9yVBTftY=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru = {
    tests = {
      version = testers.testVersion { package = ejson2env; };
      decryption = callPackage ./test-decryption.nix { };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Decrypt EJSON secrets and export them as environment variables";
    homepage = "https://github.com/Shopify/ejson2env";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ viraptor ];
    mainProgram = "ejson2env";
  };
})
