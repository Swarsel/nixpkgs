{
  lib,
  stdenv,
  fetchFromGitHub,
  ceph,
  go,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ceph-csi";
  version = "3.16.2";

  src = fetchFromGitHub {
    owner = "ceph";
    repo = "ceph-csi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jdBBRSkmNgwYzNUDY9Aarp0HNHsUcSNkZD+Fvv8drHQ=";
  };

  strictDeps = true;
  nativeBuildInputs = [ go ];
  buildInputs = [ ceph ];

  preConfigure = ''
    export GOCACHE=$(pwd)/.cache
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ./_output/* $out/bin
    runHook postInstall
  '';

  meta = {
    description = "Container Storage Interface (CSI) driver for Ceph RBD and CephFS";
    homepage = "https://ceph.com/";
    changelog = "https://github.com/ceph/ceph-csi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ johanot ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "cephcsi";
    downloadPage = "https://github.com/ceph/ceph-csi";
  };
})
