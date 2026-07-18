{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "pgscv";
  version = "0.15.2";

  src = fetchFromGitHub {
    owner = "CHERTS";
    repo = "pgscv";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1SvqLMwDmWUtRNTaBsdQnXAPsUYh8Fvu4tMmnelX+AI=";
  };

  vendorHash = "sha256-FhFiNRojBPRv8ZSJaGDlekDBcVWOPAVqoI0BuVzRNeI=";
  # tests rely on a pretty complex Postgres setup
  doCheck = false;

  postInstall = ''
    mv $out/bin/{cmd,pgscv}
  '';

  ldflags = [
    "-X=main.appName=pgscv"
    "-X=main.gitTag=${finalAttrs.src.tag}"
    "-X=main.gitCommit=${finalAttrs.src.tag}"
    "-X=main.gitBranch=${finalAttrs.src.tag}"
  ];

  meta = {
    description = "PostgreSQL ecosystem metrics collector";
    homepage = "https://github.com/CHERTS/pgscv/";
    changelog = "https://github.com/CHERTS/pgscv/releases/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ k900 ];
    platforms = lib.platforms.linux;
    mainProgram = "pgscv";
  };
})
