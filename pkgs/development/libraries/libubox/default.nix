{
  lib,
  stdenv,
  cmake,
  fetchgit,
  json_c,
  lua5_1,
  pkg-config,
  ustream-ssl,
  with_lua ? false,
  with_ustream_ssl ? false,
}:

stdenv.mkDerivation {
  pname = "libubox";
  version = "0-unstable-2025-10-14";

  src = fetchgit {
    url = "https://git.openwrt.org/project/libubox.git";
    rev = "7d6b9d98d0bdd4e14aedeb7908c28e4b318c8191";
    hash = "sha256-SBw83zT/tMvmndo4bZ19sLWc493G2jefMhrvqjQ6WJc=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    json_c
  ]
  ++ lib.optional with_lua lua5_1
  ++ lib.optional with_ustream_ssl ustream-ssl;

  cmakeFlags = [
    "-DBUILD_EXAMPLES=OFF"
    (if with_lua then "-DLUAPATH=${placeholder "out"}/lib/lua" else "-DBUILD_LUA=OFF")
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) [
      "-Wno-error=gnu-folding-constant"
    ]
  );

  postInstall = lib.optionalString with_ustream_ssl ''
    for fin in $(find ${ustream-ssl} -type f); do
      fout="''${fin/"${ustream-ssl}"/"''${out}"}"
      ln -s "$fin" "$fout"
    done
  '';

  meta = {
    description = "C utility functions for OpenWrt";
    homepage = "https://git.openwrt.org/?p=project/libubox.git;a=summary";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      fpletz
      mkg20001
      dvn0
    ];

    platforms = lib.platforms.all;
    mainProgram = "jshn";
  };
}
