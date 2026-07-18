{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  flex,
  libmemcached,
  libpq,
  libxcrypt,
  openldap,
  openssl,
  pam,
  versionCheckHook,
  enableLdap ? true,
  enableMemcached ? true,
  enablePam ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pgpool";
  version = "4.7.2";

  src = fetchFromGitHub {
    owner = "pgpool";
    repo = "pgpool2";
    tag = "V${lib.replaceString "." "_" finalAttrs.version}";
    hash = "sha256-gURWz9NeiHLL5DbUP7WnByHzCrLaI/8HWTRU9xO22EY=";
  };

  outputs = [
    "out"
    "dev"
    "lib"
  ];

  patches = [
    # Build checks for strlcpy being available in the system, but doesn't
    # actually exclude its own copy from being built
    ./darwin-strlcpy.patch
    # Fix strchrnul not available on Darwin
    ./darwin-strchrnul.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
  ];

  buildInputs = [
    libpq
    libxcrypt
    openssl
  ]
  ++ lib.optional enableLdap openldap
  ++ lib.optional enableMemcached libmemcached
  ++ lib.optional enablePam pam;

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    (lib.withFeature true "openssl")
    (lib.withFeature enableLdap "ldap")
    (lib.withFeature enablePam "pam")
    (lib.withFeatureAs enableMemcached "memcached" (lib.getDev libmemcached))
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals (stdenv.cc.isClang) [
      "-Wno-error=implicit-function-declaration"
    ]
  );

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  enableParallelBuilding = true;

  installFlags = [
    "sysconfdir=\${out}/etc"
  ];

  meta = {
    description = "Middleware that works between PostgreSQL servers and PostgreSQL clients";
    homepage = "https://pgpool.net/";

    changelog = "https://www.pgpool.net/docs/latest/en/html/release-${
      lib.replaceString "." "-" finalAttrs.version
    }.html";

    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ anthonyroussel ];
    platforms = lib.platforms.unix;
    mainProgram = "pgpool";
  };
})
