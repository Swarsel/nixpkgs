{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeWrapper,
  nodejs,
  pnpmConfigHook,
  pnpm_11,
  python3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ansible-language-server";
  version = finalAttrs.vscodeAnsibleVersion; # Language server version from the repo at packages/ansible-language-server/package.json is stuck at 0.0.0

  src = fetchFromGitHub {
    owner = "ansible";
    repo = "vscode-ansible";
    tag = "v${finalAttrs.vscodeAnsibleVersion}";
    hash = "sha256-GmeEVZumm+dfQFYLL8+Lf5usPw17a0vOZIe7ApTzFGI=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpmConfigHook
    pnpm_11
  ];

  buildPhase = ''
    runHook preBuild
    pnpm --filter=@ansible/ansible-language-server run build:dist
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/ansible-language-server
    mkdir -p $out/bin

    mv packages/ansible-language-server/dist/* $out/lib/node_modules/ansible-language-server/

    makeWrapper ${lib.getExe nodejs} $out/bin/ansible-language-server \
      --prefix PATH : ${python3}/bin \
      --add-flags "$out/lib/node_modules/ansible-language-server/server.cjs" \
      --set NODE_PATH "$out/lib/node_modules/"
    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pnpmWorkspaces
      pname
      version
      src
      ;

    fetcherVersion = 4;
    hash = "sha256-BJkPE4dNDNIUL6+LeFXTTCWNf5njItHuM/rHMkmxLJk=";
    pnpm = pnpm_11;
  };

  pnpmWorkspaces = [ "@ansible/ansible-language-server" ];
  vscodeAnsibleVersion = "26.6.0"; # vscode-ansible version

  meta = {
    description = "Ansible Language Server";
    homepage = "https://github.com/ansible/vscode-ansible";
    changelog = "https://github.com/ansible/vscode-ansible/releases/tag/v${finalAttrs.vscodeAnsibleVersion}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dtvillafana
      robsliwi
    ];

    mainProgram = "ansible-language-server";
  };
})
