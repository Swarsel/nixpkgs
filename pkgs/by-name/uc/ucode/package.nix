{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  json_c,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ucode";
  version = "0.0.20250529";

  src = fetchFromGitHub {
    owner = "jow-";
    repo = "ucode";
    rev = "v${finalAttrs.version}";
    hash = "sha256-V8WGd4rSuCtGIA5oTfnagp0Dmh5FNG87/MJSeILtbM4=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    json_c
  ];

  meta = {
    description = "JavaScript-like language with optional templating";
    homepage = "https://github.com/jow-/ucode";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ mkg20001 ];
    platforms = lib.platforms.unix;
  };
})
