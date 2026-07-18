{
  lib,
  fetchFromGitLab,
  installShellFiles,
  mdbook,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "engage";
  version = "0.3.0";

  src = fetchFromGitLab {
    owner = "charles";
    repo = "engage";
    rev = "v${finalAttrs.version}";
    hash = "sha256-dKnpovsBcx3fyDK2eSVf4vzJaQ0uNGcKoYSE56kUDEg=";
    domain = "gitlab.computer.surgery";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-wHPjVP/hzMdmKVYDzjUGoaSKwcf7A9nYeM5HhvBQ+bc=";

  env = {
    ENGAGE_BOOK_PATH = "${placeholder "out"}/share/doc/${finalAttrs.pname}";
  };

  postInstall = ''
    installShellCompletion --cmd engage ${
      builtins.concatStringsSep " " (
        map (shell: "--${shell} <(cargo xtask completions ${shell})") [
          "bash"
          "zsh"
          "fish"
        ]
      )
    }

    ${lib.getExe mdbook} build
    mkdir -p $out/share/doc
    mv public $out/share/doc/${finalAttrs.pname}
  '';

  buildAndTestSubdir = "crates/engage";

  meta = {
    description = "Process composer with ordering and parallelism based on directed acyclic graphs";
    homepage = "https://engage.computer.surgery";
    changelog = "https://engage.computer.surgery/changelog.html";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ CobaltCause ];
    mainProgram = "engage";
  };
})
