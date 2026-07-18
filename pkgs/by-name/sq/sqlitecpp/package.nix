{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sqlitecpp";
  version = "3.3.3";

  src = fetchFromGitHub {
    owner = "SRombauts";
    repo = "sqlitecpp";
    rev = finalAttrs.version;
    hash = "sha256-RSNJGfvIvNfk+/Awzh06tDi/TA5Wc35X8ya0X5mP9IE=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    sqlite
    gtest
  ];

  cmakeFlags = [
    "-DSQLITECPP_INTERNAL_SQLITE=OFF"
    "-DSQLITECPP_BUILD_TESTS=ON"
  ];

  doCheck = true;

  meta = {
    description = "C++ SQLite3 wrapper";
    homepage = "https://srombauts.github.io/SQLiteCpp/";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.jbedo
      lib.maintainers.doronbehar
    ];

    platforms = lib.platforms.unix;
  };
})
