{
  lib,
  stdenv,
  cmake,
  fetchgit,
  json_c,
  libubox,
  pkg-config,
  ubus,
  ucode,
}:

stdenv.mkDerivation {
  pname = "udebug";
  version = "unstable-2025-09-28";

  src = fetchgit {
    url = "https://git.openwrt.org/project/udebug.git";
    rev = "5327524e715332daaebf6b04c155d2880d230979";
    hash = "sha256-Zcbbo7Jo7JxNSjUlbB2m2Id8crdxzKc/QFeduPGvows=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    ubus
    libubox
    ucode
    json_c
  ];

  meta = {
    description = "OpenWrt debugging helper library/service";
    homepage = "https://git.openwrt.org/?p=project/udebug.git;a=summary";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ mkg20001 ];
    platforms = lib.platforms.unix;
    mainProgram = "udebugd";
  };
}
