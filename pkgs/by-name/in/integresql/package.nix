{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "integresql";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "allaboutapps";
    repo = "integresql";
    rev = "v${finalAttrs.version}";
    hash = "sha256-heRa1H4ZSCZzSMCejhakBpJfnEnGQLmNFERKqMxbC04=";
  };

  vendorHash = "sha256-8qI7mLgQB0GK2QV6tZmWU8hJX+Ax1YhEPisQbjGoJRc=";
  doCheck = false;

  postInstall = ''
    mv $out/bin/server $out/bin/integresql
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/allaboutapps/integresql/internal/config.Commit=${finalAttrs.src.rev}"
    "-X github.com/allaboutapps/integresql/internal/config.ModuleName=github.com/allaboutapps/integresql"
  ];

  meta = {
    description = "Manages isolated PostgreSQL databases for your integration tests";
    homepage = "https://github.com/allaboutapps/integresql";
    changelog = "https://github.com/allaboutapps/integresql/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "integresql";
  };
})
