{
  lib,
  stdenv,
  fetchFromGitLab,
  cmocka,
  lua5_3,
  meson,
  ninja,
  openssl,
  pkg-config,
  python3,
  scdoc,
  zlib,
  zstd,
  luaSupport ? stdenv.hostPlatform == stdenv.buildPlatform,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apk-tools";
  version = "3.0.5";

  src = fetchFromGitLab {
    owner = "alpine";
    repo = "apk-tools";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-iuJFgsn4yfQYqichMVhnOHFYj+5xPZYnXaCW0ZkKbRU=";
    domain = "gitlab.alpinelinux.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
  ]
  ++ lib.optionals luaSupport [
    lua5_3
    lua5_3.pkgs.lua-zlib
  ];

  buildInputs = [
    openssl
    zlib
    zstd
    scdoc
    cmocka
  ]
  ++ lib.optional luaSupport lua5_3;

  mesonFlags = [
    (lib.mesonEnable "lua" luaSupport)
    (lib.mesonOption "lua_bin" "lua")
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Alpine Package Keeper";
    homepage = "https://gitlab.alpinelinux.org/alpine/apk-tools";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "apk";
  };
})
