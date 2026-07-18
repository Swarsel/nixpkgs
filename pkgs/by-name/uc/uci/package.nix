{
  lib,
  stdenv,
  cmake,
  fetchgit,
  libubox,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "uci";
  version = "unstable-2025-10-12";

  src = fetchgit {
    url = "https://git.openwrt.org/project/uci.git";
    rev = "57c1e8cd2c051d755ca861a9ab38a8049d2e3f95";
    hash = "sha256-/Ian7WoBvm9nmniHdVTEIyRW1BPTmOe3O0v59aDaXc0=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ libubox ];
  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
  hardeningDisable = [ "all" ];

  meta = {
    description = "OpenWrt Unified Configuration Interface";
    homepage = "https://git.openwrt.org/?p=project/uci.git;a=summary";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ mkg20001 ];
    platforms = lib.platforms.all;
    mainProgram = "uci";
  };
}
