{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nixosTests,
  symlinkJoin,
}:

let
  version = "3.6.13";
  etcdSrcHash = "sha256-L6wnvexUxFlN4r2D9rIQPDIYWMvs6DqY8eWU1FToi3M=";
  etcdCtlVendorHash = "sha256-UKuxCQi1RriPvX9cM+Nd1jXs/H0smwJJU9CEM/cI/sA=";
  etcdUtlVendorHash = "sha256-molkWWxxKLCCbocqVaij1jcHeoYYHSuI/cAfieeZH+0=";
  etcdServerVendorHash = "sha256-o58rJPOSeT14SAEjBSbXwPDuAsOT/YNAqZRCM15unJQ=";

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
    downloadPage = "https://github.com/etcd-io/etcd";
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
    nativeBuildInputs = [ installShellFiles ];
    vendorHash = etcdUtlVendorHash;

    postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      for shell in bash fish zsh; do
        installShellCompletion --cmd etcdutl \
          --$shell <($out/bin/etcdutl completion $shell)
      done
    '';

    __darwinAllowLocalNetworking = true;
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
    nativeBuildInputs = [ installShellFiles ];
    vendorHash = etcdCtlVendorHash;

    postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      for shell in bash fish zsh; do
        installShellCompletion --cmd etcdctl \
          --$shell <($out/bin/etcdctl completion $shell)
      done
    '';

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

    tests = nixosTests.etcd."3_6";
    updateScript = ./update.sh;
  };
}
