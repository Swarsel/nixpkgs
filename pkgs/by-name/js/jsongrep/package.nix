{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  rustPlatform,
  stdenvNoCC,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jsongrep";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "micahkepe";
    repo = "jsongrep";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rDt4jtrC+KuPKdEoReVWW8R9/sKBnalnRuB4bj1tzas=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-VJ8ZB3oVppMRsSvpVOF1SIvOtI0rcS8elJEweoum/lY=";

  postInstall = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    for shell in bash fish zsh; do
      installShellCompletion --cmd jg \
        --"$shell" <("$out"/bin/jg generate shell "$shell")
    done
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "JSONPath-inspired query language";

    longDescription = ''
      `jsongrep` is a command-line tool and Rust library for querying
      JSON documents using regular path expressions.
    '';

    homepage = "https://github.com/micahkepe/jsongrep";
    changelog = "https://github.com/micahkepe/jsongrep/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yiyu ];
    mainProgram = "jg";
  };
})
