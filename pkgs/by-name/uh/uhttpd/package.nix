{
  lib,
  stdenv,
  cmake,
  fetchgit,
  json_c,
  libubox,
  libxcrypt,
  lua5_1,
  makeWrapper,
  pkg-config,
  ubus,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "uhttpd";
  version = "0-unstable-2025-12-24";

  src = fetchgit {
    url = "https://git.openwrt.org/project/uhttpd.git";
    rev = "506e24987b97fbc866005bfb71316bd63601a1ef";
    hash = "sha256-x5hbbEcyxWhCjjqiHvAxvI1eHewqRlXuAGqXNw+c4sA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    lua5_1
    json_c
    libubox
    ubus
    libxcrypt
  ];

  cmakeFlags = [
    "-DUCODE_SUPPORT=off"
    "-DTLS_SUPPORT=on"
    "-DLUA_SUPPORT=on"
  ];

  env.NIX_LDFLAGS = "-lcrypt";

  postInstall = ''
    wrapProgram $out/bin/uhttpd \
      --prefix LD_LIBRARY_PATH : $out/lib/uhttpd
  '';

  passthru.updateScript = unstableGitUpdater {
    branch = "master";
    hardcodeZeroVersion = true;
  };

  meta = {
    description = "Tiny HTTP server from OpenWrt project";
    homepage = "https://openwrt.org/docs/guide-user/services/webserver/uhttpd";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.haylin ];
    platforms = lib.platforms.unix;
    mainProgram = "uhttpd";
  };
})
