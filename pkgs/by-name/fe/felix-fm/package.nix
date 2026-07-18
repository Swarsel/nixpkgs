{
  lib,
  fetchFromGitHub,
  bzip2,
  libgit2,
  nix-update-script,
  pkg-config,
  rustPlatform,
  zlib,
  zoxide,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "felix";
  version = "2.16.1";

  src = fetchFromGitHub {
    owner = "kyoheiu";
    repo = "felix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QslV0MVbIuiFDmd8A69+7nTPAUhDrn/dndZsIiNkeZ8=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    bzip2
    libgit2
    zlib
    zstd
  ];

  cargoHash = "sha256-1JjvfXyjGUHIwJJAlI2pB829kHcPrVmKOp+msDk5Qp4=";

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  nativeCheckInputs = [ zoxide ];

  checkFlags = [
    # extra test files not shipped with the repository
    "--skip=functions::tests::test_list_up_contents"
    "--skip=state::tests::test_has_write_permission"
  ];

  buildFeatures = [ "zstd/pkg-config" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tui file manager with vim-like key mapping";
    homepage = "https://github.com/kyoheiu/felix";
    changelog = "https://github.com/kyoheiu/felix/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _7karni ];
    mainProgram = "fx";
  };
})
