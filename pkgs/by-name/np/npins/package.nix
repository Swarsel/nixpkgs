{
  lib,
  stdenv,
  fetchFromGitHub,
  git, # for git ls-remote
  installShellFiles,
  makeWrapper,
  nix-prefetch-docker,
  # runtime dependencies
  nix-prefetch-git,
  rustPlatform,
}:

let
  runtimePath = lib.makeBinPath [
    nix-prefetch-git
    nix-prefetch-docker
    git
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "npins";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "andir";
    repo = "npins";
    tag = finalAttrs.version;
    sha256 = "sha256-OkPEh0axWs3gUoUyplQexYpEXxyCDYWm5BQpwB2PIqA=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  cargoHash = "sha256-ZbdAvt2FRq5fHS0RRndeCrpY3j8Lvn2oTAECteIss5A=";
  # (Almost) all tests require internet
  doCheck = false;

  postFixup =
    lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd npins \
        --bash <($out/bin/npins-completions bash) \
        --fish <(cat <($out/bin/npins-completions fish) $src/completions/pin-completions.fish) \
        --zsh <($out/bin/npins-completions zsh)

      rm $out/bin/npins-completions
    ''
    + ''
      wrapProgram $out/bin/npins --prefix PATH : "${runtimePath}"
    '';

  cargoBuildFlags = [
    "-p"
    "npins"
    "-p"
    "npins-completions"
  ];

  meta = {
    description = "Simple and convenient dependency pinning for Nix";
    homepage = "https://github.com/andir/npins";
    license = lib.licenses.eupl12;

    maintainers = with lib.maintainers; [
      piegames
      coca
    ];

    mainProgram = "npins";
  };
})
