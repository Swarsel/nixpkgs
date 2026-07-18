{
  lib,
  symlinkJoin,
  tdarr-node,
  tdarr-server,
}:

symlinkJoin {
  inherit (tdarr-server) version;
  pname = "tdarr";
  name = "tdarr-${tdarr-server.version}";

  paths = [
    tdarr-server
    tdarr-node
  ];

  passthru = {
    node = tdarr-node;
    server = tdarr-server;
    tests = tdarr-server.tests or { } // tdarr-node.tests or { };
  };

  meta = {
    description = "Distributed transcode automation using FFmpeg/HandBrake (includes both server and node)";
    homepage = "https://tdarr.io";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ mistyttm ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
