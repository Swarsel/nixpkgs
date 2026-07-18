{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  installShellFiles,
  nix,
  rustPlatform,
}:
let
  version = "0.5.3";
in
rustPlatform.buildRustPackage rec {
  inherit version;
  pname = "mdbook";

  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = "mdBook";
    tag = "v${version}";
    hash = "sha256-RMJQn58hshBGQSpu30NdUOb3Prywn6NfhauSzFZ35xQ=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-LlImOjTQjMQURQ81Gn73v+DEHXqyyiz39K9T+MrE7S0=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd mdbook \
      --bash <($out/bin/mdbook completions bash) \
      --fish <($out/bin/mdbook completions fish) \
      --zsh  <($out/bin/mdbook completions zsh )
  '';

  passthru = {
    tests = {
      inherit nix;
    };
  };

  meta = {
    description = "Create books from MarkDown";
    homepage = "https://github.com/rust-lang/mdBook";
    changelog = "https://github.com/rust-lang/mdBook/blob/v${version}/CHANGELOG.md";
    license = [ lib.licenses.mpl20 ];

    maintainers = with lib.maintainers; [
      Frostman
      matthiasbeyer
    ];

    mainProgram = "mdbook";
  };
}
