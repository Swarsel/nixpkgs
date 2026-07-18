{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nlohmann_json,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nlohmann_json_schema_validator";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "pboettch";
    repo = "json-schema-validator";
    rev = finalAttrs.version;
    hash = "sha256-VTRnlkcSPMCRQiu5H2P44nHG1JMV9gl04xYjppstsk4=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ nlohmann_json ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ];

  meta = {
    description = "JSON schema validator for JSON for Modern C++";
    homepage = "https://github.com/pboettch/json-schema-validator";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ br337 ];
    platforms = lib.platforms.all;
  };
})
