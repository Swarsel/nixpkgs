{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "unixodbc";
  version = "2.3.14";

  src = fetchFromGitHub {
    owner = "lurcher";
    repo = "unixODBC";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2WhUnpiNTtsoOJ4rvdxaadcW1ROWfdoSVA8Crj8rpo8=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  configureFlags = [
    "--disable-gui"
    "--sysconfdir=/etc"
  ];

  meta = {
    description = "ODBC driver manager for Unix";
    homepage = "https://www.unixodbc.org/";
    changelog = "https://github.com/lurcher/unixODBC/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl2;
    maintainers = with lib.maintainers; [ hythera ];
    platforms = lib.platforms.unix;
  };
})
