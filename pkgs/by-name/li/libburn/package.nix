{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromGitea,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libburn";
  version = "1.5.8";

  src = fetchFromGitea {
    owner = "libburnia";
    repo = "libburn";
    rev = "release-${finalAttrs.version}";
    hash = "sha256-W/9dUUQGB1V76G9YshNjJcrptAuVVcsXiM5ZQ9Q50Xs=";
    domain = "dev.lovelyhq.com";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  meta = {
    description = "Library by which preformatted data get onto optical media: CD, DVD, BD (Blu-Ray)";
    homepage = "https://dev.lovelyhq.com/libburnia/web/wiki";
    changelog = "https://dev.lovelyhq.com/libburnia/libburn/src/tag/${finalAttrs.src.rev}/ChangeLog";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "cdrskin";
  };
})
