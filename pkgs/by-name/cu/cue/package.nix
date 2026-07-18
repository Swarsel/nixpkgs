{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  installShellFiles,
  pkgs,
  testers,
  tests,
}:

buildGoModule (finalAttrs: {
  pname = "cue";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "cue-lang";
    repo = "cue";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+mfGN2IX83JMwLsduBfj2h7Eeve6mmLpmXGFRxz/UfI=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-dTUg6EnU6xKCGve9ksxqBF3BaoBdVlXFU8pTyZtV+RA=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd cue \
      --bash <($out/bin/cue completion bash) \
      --fish <($out/bin/cue completion fish) \
      --zsh <($out/bin/cue completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X cuelang.org/go/cmd/cue/cmd.version=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/*" ];

  passthru =
    let
      cue = finalAttrs.finalPackage;
      writeCueValidator = callPackage ./validator.nix { inherit cue; };
    in
    {
      inherit writeCueValidator;

      tests = {
        version = testers.testVersion {
          version = "v${finalAttrs.version}";
          command = "cue version";
          package = cue;
        };

        test-001-all-good = callPackage ./tests/001-all-good.nix { inherit cue; };

        validation = tests.cue-validation.override {
          pkgs = pkgs.extend (_: _: { inherit writeCueValidator; });
        };
      };
    };

  meta = {
    description = "Data constraint language which aims to simplify tasks involving defining and using data";
    homepage = "https://cuelang.org/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aaronjheng ];
    mainProgram = "cue";
  };
})
