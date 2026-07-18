{
  lib,
  fetchFromGitLab,
  gitMinimal,
  gnupg,
  installShellFiles,
  libfaketime,
  nettle,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
  ...
}:
rustPlatform.buildRustPackage (final: {
  pname = "sequoia-git";
  version = "0.6.0";

  src = fetchFromGitLab {
    owner = "sequoia-pgp";
    repo = "sequoia-git";
    rev = "v${final.version}";
    hash = "sha256-1nSFzpz0Rl9uoE59teP3o7PduSmA20QEhe+fvTM6JGA=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    installShellFiles
  ];

  buildInputs = [
    openssl.dev
    nettle.dev
    sqlite.dev
  ];

  cargoHash = "sha256-/9/nTqCRi74TMToWQjtnnzQ8en+nqKT8gUipNcHTxvs=";
  env.ASSET_OUT_DIR = "target";

  nativeCheckInputs = [
    gnupg
    gitMinimal
    libfaketime
  ];

  postInstall = ''
    installManPage ${final.env.ASSET_OUT_DIR}/man-pages/*.1
    installShellCompletion --bash ${final.env.ASSET_OUT_DIR}/shell-completions/${final.meta.mainProgram}.bash
    installShellCompletion --zsh ${final.env.ASSET_OUT_DIR}/shell-completions/_${final.meta.mainProgram}
    installShellCompletion --fish ${final.env.ASSET_OUT_DIR}/shell-completions/${final.meta.mainProgram}.fish
  '';

  __structuredAttrs = true;

  meta = {
    homepage = "https://sequoia-pgp.gitlab.io/sequoia-git";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ lib.maintainers.matthiasbeyer ];
    mainProgram = "sq-git";
  };
})
