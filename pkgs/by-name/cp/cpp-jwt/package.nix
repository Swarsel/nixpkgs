{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
  nlohmann_json,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpp-jwt";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "arun11299";
    repo = "cpp-jwt";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-TyLYTk7vlpNmYJxaH9zhGwFvv1BEcShTDr7JYfgu6f0=";
  };

  strictDeps = true;
  nativeBuildInputs = [ cmake ];

  buildInputs = [
    gtest
    openssl
    nlohmann_json
  ];

  cmakeFlags = [
    "-DCPP_JWT_USE_VENDORED_NLOHMANN_JSON=OFF"
    "-DCPP_JWT_BUILD_EXAMPLES=OFF"
  ];

  doCheck = true;

  meta = {
    description = "JSON Web Token library for C++";
    homepage = "https://github.com/arun11299/cpp-jwt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fpletz ];
  };
})
