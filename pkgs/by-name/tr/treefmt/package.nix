{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  callPackages,
  installShellFiles,
}:
buildGoModule (finalAttrs: {
  pname = "treefmt";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "numtide";
    repo = "treefmt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-aZzbw5dQGLNqvfENNX6dtkxgjjMeL53l4mIeVpQpprA=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-FoXzUsioqTcdtNNKL9X9MhCXysH+bxabITqOUd+bmHE=";
  env.CGO_ENABLED = 1;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd treefmt \
      --bash <($out/bin/treefmt --completion bash) \
      --fish <($out/bin/treefmt --completion fish) \
      --zsh <($out/bin/treefmt --completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/numtide/treefmt/v2/build.Name=treefmt"
    "-X github.com/numtide/treefmt/v2/build.Version=v${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  passthru = {
    inherit (callPackages ./lib.nix { })
      evalConfig
      withConfig
      buildConfig
      ;

    # Documentation for functions defined in `./lib.nix`
    functionsDoc = callPackages ./functions-doc.nix { };
    # Documentation for options declared in `treefmt.evalConfig` configurations
    optionsDoc = callPackages ./options-doc.nix { };
    tests = callPackages ./tests.nix { };
  };

  meta = {
    description = "One CLI to format the code tree";

    longDescription = ''
      [treefmt](${finalAttrs.meta.homepage}) streamlines the process of applying formatters
      to your project, making it a breeze with just one command line.

      The `treefmt` package provides functions for configuring treefmt using
      the module system, which are documented in the [treefmt section] of the
      Nixpkgs Manual.

      Alternatively, treefmt can be configured using [treefmt-nix].

      [treefmt section]: https://nixos.org/manual/nixpkgs/unstable#treefmt
      [treefmt-nix]: https://github.com/numtide/treefmt-nix
    '';

    homepage = "https://github.com/numtide/treefmt";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      brianmcgee
      MattSturgeon
      zimbatm
    ];

    mainProgram = "treefmt";
  };
})
