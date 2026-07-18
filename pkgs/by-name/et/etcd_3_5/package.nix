{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
  symlinkJoin,
}:

let
  version = "3.5.32";
  etcdSrcHash = "sha256-pqCMgY5veIF5kQDjqTg9B7aSL+V6bdMZpc464wjTLMo=";
  etcdServerVendorHash = "sha256-FDzAF2J9wbRmQETvrdJK3gL4cfAhiiihb5EOrimE11M=";
  etcdUtlVendorHash = "sha256-0xfq7f7Xr3SWxiU8C1bWQPxdFvEaoIrlK+gX3hkd4ho=";
  etcdCtlVendorHash = "sha256-59e/TORi/XX+GXRjMO/45SMumYgrFbOHEXqV7sM72H8=";

  src = fetchFromGitHub {
    owner = "etcd-io";
    repo = "etcd";
    tag = "v${version}";
    hash = etcdSrcHash;
  };

  env = {
    CGO_ENABLED = 0;
  };

  meta = {
    description = "Distributed reliable key-value store for the most critical data of a distributed system";
    homepage = "https://etcd.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dtomvan ];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
  };

  etcdserver = buildGoModule {
    inherit
      env
      meta
      src
      version
      ;

    pname = "etcdserver";
    vendorHash = etcdServerVendorHash;

    preInstall = ''
      mv $GOPATH/bin/{server,etcd}
    '';

    __darwinAllowLocalNetworking = true;
    # We set the GitSHA to `GitNotFound` to match official build scripts when
    # git is unavailable. This is to avoid doing a full Git Checkout of etcd.
    # User facing version numbers are still available in the binary, just not
    # the sha it was built from.
    ldflags = [ "-X go.etcd.io/etcd/api/v3/version.GitSHA=GitNotFound" ];
    modRoot = "./server";
  };

  etcdutl = buildGoModule {
    inherit
      env
      meta
      src
      version
      ;

    pname = "etcdutl";
    vendorHash = etcdUtlVendorHash;
    modRoot = "./etcdutl";
  };

  etcdctl = buildGoModule {
    inherit
      env
      meta
      src
      version
      ;

    pname = "etcdctl";
    vendorHash = etcdCtlVendorHash;
    modRoot = "./etcdctl";
  };
in
symlinkJoin {
  inherit meta version;
  pname = "etcd";

  paths = [
    etcdserver
    etcdutl
    etcdctl
  ];

  passthru = {
    deps = {
      inherit etcdserver etcdutl etcdctl;
    };

    tests = nixosTests.etcd."3_5";
    updateScript = ./update.sh;
  };
}
