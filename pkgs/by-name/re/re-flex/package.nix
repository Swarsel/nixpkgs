{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "re-flex";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "Genivia";
    repo = "RE-flex";
    rev = "v${finalAttrs.version}";
    hash = "sha256-p04o2e7Dxx7N6ByCwERz4hKz+vfTIuuZ//AoWSC1qao=";
  };

  outputs = [
    "out"
    "bin"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    description = "Regex-centric, fast lexical analyzer generator for C++ with full Unicode support";
    homepage = "https://www.genivia.com/doc/reflex/html";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ prrlvr ];
    platforms = lib.platforms.all;
    mainProgram = "reflex";
  };
})
