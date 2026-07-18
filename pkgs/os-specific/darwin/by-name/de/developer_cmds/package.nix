{
  lib,
  buildPackages,
  clang,
  mkAppleDerivation,
  shell_cmds,
}:

mkAppleDerivation {
  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    substituteInPlace rpcgen/rpc_main.c \
      --replace-fail '/usr/bin/cpp' '${lib.getBin buildPackages.clang}/bin/${buildPackages.clang.targetPrefix}cpp'
  '';

  postInstall = ''
    HOST_PATH='${lib.getBin shell_cmds}/bin' patchShebangs --host "$out/bin"
  '';

  releaseName = "developer_cmds";
  xcodeHash = "sha256-25SDn9+SzEZJPQQJaDxsxWKeUetNHhzliLfzD9BtyyI=";

  meta = {
    description = "Developer commands for Darwin";

    license = [
      lib.licenses.bsd3
      lib.licenses.bsdOriginal
    ];
  };
}
