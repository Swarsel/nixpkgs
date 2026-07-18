{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

let
  stubsSrc = fetchFromGitHub {
    hash = "sha256-IDWAuy301avfTF/E7Mby2JQQtIr/gnN5flZ3uctUpus=";
    owner = "JetBrains";
    repo = "phpstorm-stubs";
    rev = "517b9ad1adaf2c5453c00ec2fbb02d192a4a9b6c";
  };
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "phpantom-lsp";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "AJenbo";
    repo = "phpantom_lsp";
    tag = finalAttrs.version;
    hash = "sha256-00NAiPm3qqxyS1u1GPpJlgnBlUjDx9VmjK6oOwH8kcU=";
  };

  postPatch = ''
    mkdir -p stubs/jetbrains
    cp -a ${finalAttrs.passthru.stubsSrc} stubs/jetbrains/phpstorm-stubs
    chmod u+wx stubs/jetbrains/phpstorm-stubs

    echo "${finalAttrs.passthru.stubsSrc.rev}" \
      > stubs/jetbrains/phpstorm-stubs/.commit
  '';

  cargoHash = "sha256-FyMI8Kb3QUD8Jui9k7vayMcQC+KWL8sZi3A05NPbXsg=";

  checkFlags = [
    "--test"
    "completion_inheritance"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  passthru = {
    inherit stubsSrc;

    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script { })
      ./update-php-stubs.sh
    ];
  };

  meta = {
    description = "Fast, lightweight PHP language server written in Rust";
    homepage = "https://github.com/AJenbo/phpantom_lsp";
    changelog = "https://github.com/AJenbo/phpantom_lsp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
    mainProgram = "phpantom_lsp";
  };
})
