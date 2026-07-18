{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "honeycomb-refinery";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "honeycombio";
    repo = "refinery";
    rev = "v${finalAttrs.version}";
    hash = "sha256-slINvCsw4s5I9s9LaTXuR/5Rvv1K1qzqNiatwr6p4FM=";
  };

  patches = [
    # Allows turning off the one test requiring a Redis service during build.
    # We could in principle implement that, but it's significant work to little
    # payoff.
    ./0001-add-NO_REDIS_TEST-env-var-that-disables-Redis-requir.patch
  ];

  vendorHash = "sha256-DxqVKGox3NbRwvkGrW29MbsE4KKK0/Og8uH5hgtgPMo=";
  env.NO_REDIS_TEST = true;
  doCheck = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  excludedPackages = [
    "LICENSES"
    "cmd/test_redimem"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.BuildID=${finalAttrs.version}"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tail-sampling proxy for OpenTelemetry";
    homepage = "https://github.com/honeycombio/refinery";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      jkachmar
      lf-
    ];

    mainProgram = "refinery";
  };
})
