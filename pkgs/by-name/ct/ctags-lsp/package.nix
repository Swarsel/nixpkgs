{
  lib,
  fetchFromGitHub,
  buildGoModule,
  git,
  jujutsu,
  makeWrapper,
  nix-update-script,
  universal-ctags,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "ctags-lsp";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "netmute";
    repo = "ctags-lsp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8cknVcXIuV7mmRMm87jn2l3qrfaY3CGzCZ0VW5Vb9xk=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = null;

  postInstall = ''
    wrapProgram $out/bin/ctags-lsp \
      --suffix PATH : ${
        lib.makeBinPath [
          universal-ctags
          git
          jujutsu
        ]
      }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "LSP implementation using universal-ctags as backend";
    homepage = "https://github.com/netmute/ctags-lsp";
    changelog = "https://github.com/netmute/ctags-lsp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ voronind ];
    mainProgram = "ctags-lsp";
  };
})
