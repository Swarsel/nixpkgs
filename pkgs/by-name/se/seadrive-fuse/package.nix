{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  curl,
  fuse,
  libargon2,
  libevent,
  libsearpc,
  libuuid,
  libwebsockets,
  nix-update-script,
  pkg-config,
  python3,
  sqlite,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "seadrive-fuse";
  version = "3.0.23";

  src = fetchFromGitHub {
    owner = "haiwen";
    repo = "seadrive-fuse";
    rev = "v${finalAttrs.version}";
    hash = "sha256-s43AVVXwpF97tvwxwMDvc8t1KlrDVAv+Ta/QVRui6f8=";
  };

  nativeBuildInputs = [
    libwebsockets
    autoreconfHook
    vala
    fuse
    pkg-config
    python3
  ];

  buildInputs = [
    libargon2
    libuuid
    sqlite
    libsearpc
    libevent
    curl
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "SeaDrive daemon with FUSE interface";
    homepage = "https://github.com/haiwen/seadrive-fuse";
    changelog = "https://github.com/haiwen/seadrive-fuse/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      wenbin-liu
    ];

    platforms = lib.platforms.linux;
    mainProgram = "seadrive";
  };
})
