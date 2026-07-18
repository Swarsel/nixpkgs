{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gcc14Stdenv,
  libpq,
  postgresql,
  postgresqlTestHook,
  python3,
}:

# Work around issue reported in https://github.com/NixOS/nixpkgs/issues/476278.
# Should be solved when libpqxx 8.x is released.
gcc14Stdenv.mkDerivation (finalAttrs: {
  pname = "libpqxx";
  version = "7.10.7";

  src = fetchFromGitHub {
    owner = "jtv";
    repo = "libpqxx";
    rev = finalAttrs.version;
    hash = "sha256-A33Z6xSIReYHHS3KerBSDTuo59tixduxXVEMfa/2I7A=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    # Disable linting step for tests, it tries to install packages with pip.
    substituteInPlace Makefile.am \
      --replace-fail "TESTS = tools/lint" ""

    patchShebangs ./tools/splitconfig.py
    # Needed for autoreconfHook
    patchShebangs tools/*.py
  '';

  strictDeps = true;

  nativeBuildInputs = [
    # Needed because Makefile.am is patched to disable the tools/lint test.
    autoreconfHook
    python3
  ];

  buildInputs = [
    libpq
  ];

  configureFlags = [
    "--disable-documentation"
    "--enable-shared"
  ];

  doCheck = lib.meta.availableOn stdenv.hostPlatform postgresqlTestHook;

  nativeCheckInputs = [
    postgresql
    postgresqlTestHook
  ];

  __structuredAttrs = true;
  enableParallelBuilding = true;

  meta = {
    description = "C++ library to access PostgreSQL databases";
    homepage = "https://pqxx.org/development/libpqxx/";
    changelog = "https://github.com/jtv/libpqxx/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    downloadPage = "https://github.com/jtv/libpqxx";
  };
})
