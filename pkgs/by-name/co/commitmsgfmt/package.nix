{
  lib,
  fetchFromGitLab,
  commitmsgfmt,
  nix-update-script,
  rustPlatform,
  testers,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "commitmsgfmt";
  version = "1.7.0";

  src = fetchFromGitLab {
    owner = "mkjeldsen";
    repo = "commitmsgfmt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6mMjDMWkpaKXqmyE2taV4pDa92Tdt4VEHHLdOpRHung=";
  };

  cargoHash = "sha256-Ewn7NCFtl8phC5cFyLWZcGZy4w+huummzeuXFRn64lQ=";

  passthru.tests.version = testers.testVersion {
    command = "commitmsgfmt -V";
    package = commitmsgfmt;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Formats commit messages better than fmt(1) and Vim";
    homepage = "https://gitlab.com/mkjeldsen/commitmsgfmt";
    changelog = "https://gitlab.com/mkjeldsen/commitmsgfmt/-/raw/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mmlb ];
    mainProgram = "commitmsgfmt";
  };
})
