{
  lib,
  stdenv,
  fetchFromGitLab,
  curl,
  libevent,
  meson,
  ninja,
  pkg-config,
  spdlog,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "coeurl";
  version = "0.3.2";

  src = fetchFromGitLab {
    owner = "nheko-reborn";
    repo = "coeurl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8BwyPfLgkJG1CHnRAKxgn8ObEGSK+lKKUhQibs1dCg4=";
    domain = "nheko.im";
  };

  nativeBuildInputs = [
    ninja
    pkg-config
    meson
  ];

  buildInputs = [
    libevent
    curl
    spdlog
  ];

  meta = {
    description = "Simple async wrapper around CURL for C++";
    homepage = "https://nheko.im/nheko-reborn/coeurl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rnhmjoj ];
    platforms = lib.platforms.all;
  };
})
