{
  lib,
  fetchzip,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pr-tracker";
  version = "1.10.0";

  src = fetchzip {
    url = "https://git.qyliss.net/pr-tracker/snapshot/pr-tracker-${finalAttrs.version}.tar.xz";
    hash = "sha256-lAraMuhAvTV/PX0R/SSga3bebuK0lizcyEK7Qo3iUmc=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-gD2J3yp2ICNU9bQSXp2ks5GV+vL76t278WwiWCsAT8k=";

  meta = {
    description = "Nixpkgs pull request channel tracker";

    longDescription = ''
      A web server that displays the path a Nixpkgs pull request will take
      through the various release channels.
    '';

    homepage = "https://git.qyliss.net/pr-tracker";
    changelog = "https://git.qyliss.net/pr-tracker/plain/NEWS?h=${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      qyliss
      sumnerevans
    ];

    platforms = lib.platforms.unix;
    mainProgram = "pr-tracker";
  };
})
