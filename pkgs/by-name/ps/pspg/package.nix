{
  lib,
  stdenv,
  fetchFromGitHub,
  gnugrep,
  installShellFiles,
  libpq,
  ncurses,
  pkg-config,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pspg";
  version = "5.8.16";

  src = fetchFromGitHub {
    owner = "okbob";
    repo = "pspg";
    rev = finalAttrs.version;
    sha256 = "sha256-7x1hTEl2WoOXZTbPfb/t0w4tl09paDD/uIPuyhLlMbk=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    gnugrep
    libpq
    ncurses
    readline
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  postInstall = ''
    installManPage pspg.1
    installShellCompletion --bash --cmd pspg bash-completion.sh
  '';

  meta = {
    description = "Postgres Pager";
    homepage = "https://github.com/okbob/pspg";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.jlesquembre ];
    platforms = lib.platforms.unix;
    mainProgram = "pspg";
  };
})
