{
  lib,
  fetchFromGitHub,
  installShellFiles,
  perl,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tabiew";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "shshemi";
    repo = "tabiew";
    tag = "v${finalAttrs.version}";
    hash = "sha256-73ShTX/4q26ageg3VZdRj2mAUurYv4Uj86WpLX0k44U=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    installShellFiles
    perl
  ];

  cargoHash = "sha256-JP2qRcHgwNPjg6qjSj/E6bKmPIfBFn4MLjJ8KYce0pE=";
  doCheck = false; # there are no tests

  postInstall = ''
    installManPage target/manual/tabiew.1

    installShellCompletion \
      --bash target/completion/tw.bash \
      --zsh target/completion/_tw \
      --fish target/completion/tw.fish
  '';

  meta = {
    description = "Lightweight, terminal-based application to view and query delimiter separated value formatted documents, such as CSV and TSV files";
    homepage = "https://github.com/shshemi/tabiew";
    changelog = "https://github.com/shshemi/tabiew/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ anas ];
    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "tw";
  };
})
