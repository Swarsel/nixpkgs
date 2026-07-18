{
  lib,
  stdenv,
  fetchFromGitHub,
  brotli,
  c-ares,
  cmake,
  hiredis,
  jsoncpp,
  libmysqlclient,
  libossp_uuid,
  libpq,
  mariadb,
  # optional but of negligible size
  openssl,
  sqlite,
  zlib,
  mysqlSupport ? false,
  postgresSupport ? false,
  redisSupport ? false,
  # optional databases
  sqliteSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "drogon";
  version = "1.9.12";

  src = fetchFromGitHub {
    owner = "drogonframework";
    repo = "drogon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Rx6PpouEXW1J44oK+wCnnGQa0i+H5KSboLLATLMCBBg=";
    fetchSubmodules = true;
  };

  patches = [
    # this part of the test would normally fail because it attempts to configure a CMake project that uses find_package on itself
    # this patch makes drogon and trantor visible to the test
    ./fix_find_package.patch
  ];

  nativeBuildInputs = [ cmake ];

  propagatedBuildInputs = [
    jsoncpp
    libossp_uuid
    zlib
    openssl
    brotli
    c-ares
  ]
  ++ lib.optional sqliteSupport sqlite
  ++ lib.optional postgresSupport libpq
  ++ lib.optional redisSupport hiredis
  # drogon uses mariadb for mysql (see https://github.com/drogonframework/drogon/wiki/ENG-02-Installation#Library-Dependencies)
  ++ lib.optionals mysqlSupport [
    libmysqlclient
    mariadb
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.finalPackage.doInstallCheck)
    (lib.cmakeBool "BUILD_EXAMPLES" false)
  ];

  # this excludes you, pkgsStatic (cmake wants to run built binaries
  # in the buildPhase)
  doInstallCheck = stdenv.buildPlatform == stdenv.hostPlatform;

  # modifying PATH here makes drogon_ctl visible to the test
  installCheckPhase = ''
    (
      cd ..
      PATH=$PATH:$out/bin $SHELL test.sh
    )
  '';

  meta = {
    description = "C++14/17 based HTTP web application framework";
    homepage = "https://github.com/drogonframework/drogon";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
