{
  lib,
  fetchFromGitHub,
  buildGoModule,
  git,
  makeWrapper,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "ec";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "chojs23";
    repo = "ec";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZG4y5GS/33hHhM1OwgcwF13CfzjxT93cGUfkB8j09cY=";
  };

  postPatch = ''
    substituteInPlace cmd/ec/main.go \
      --replace-fail \
        'var version = "dev"' \
        'var version = "${finalAttrs.version}"'
  '';

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-bV5y8zKculYULkFl9J95qebLOzdTT/LuYycqMmHKZ+g=";
  nativeCheckInputs = [ git ];

  postInstall = ''
    wrapProgram $out/bin/ec --prefix PATH : ${
      lib.makeBinPath [
        git
      ]
    }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Easy terminal-native 3-way git conflict resolver vim-like workflow";
    homepage = "https://github.com/chojs23/ec";
    changelog = "https://github.com/chojs23/ec/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kpbaks
      neo
    ];

    mainProgram = "ec";
  };
})
