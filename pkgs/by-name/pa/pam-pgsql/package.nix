{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libgcrypt,
  libpq,
  libxcrypt,
  nixosTests,
  pam,
  pkg-config,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "pam-pgsql";
  version = "0-unstable-2025-01-24";

  src = fetchFromGitHub {
    owner = "pam-pgsql";
    repo = "pam-pgsql";
    rev = "7834ce21c4f633e3eadc9abe86fa02991efc43ed";
    hash = "sha256-hBkDEYZ8RBHav3tqDOD2uQ9m3U95wi4U9ebyQPqd5bo=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    libpq.pg_config
  ];

  buildInputs = [
    libgcrypt
    pam
    libpq
    libxcrypt
  ];

  passthru = {
    tests = { inherit (nixosTests) pam-pgsql; };
    updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };
  };

  meta = {
    description = "Support to authenticate against PostgreSQL for PAM-enabled applications";
    homepage = "https://github.com/pam-pgsql/pam-pgsql";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.linux;
  };
}
