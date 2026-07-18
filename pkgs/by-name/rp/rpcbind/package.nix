{
  lib,
  stdenv,
  autoreconfHook,
  fetchgit,
  libnsl,
  libtirpc,
  pkg-config,
  systemd,
  useSystemd ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rpcbind";
  version = "1.2.9";

  src = fetchgit {
    url = "git://git.linux-nfs.org/projects/steved/rpcbind.git";
    rev = "refs/tags/rpcbind-${builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-uiUGSCUkFTFl+hqzXgJEjl4WZCcMi+QxuAGmY0g+fs4=";
  };

  patches = [
    ./sunrpc.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libnsl
    libtirpc
  ]
  ++ lib.optional useSystemd systemd;

  configureFlags = [
    "--with-systemdsystemunitdir=${
      if useSystemd then "${placeholder "out"}/etc/systemd/system" else "no"
    }"
    "--enable-warmstarts"
    "--with-rpcuser=rpc"
  ];

  meta = {
    description = "ONC RPC portmapper";

    longDescription = ''
      Universal addresses to RPC program number mapper.
    '';

    homepage = "https://linux-nfs.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ zwang20 ];
    platforms = lib.platforms.unix;
  };
})
