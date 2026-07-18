{
  lib,
  stdenv,
  aardvark-dns,
  buildah-unwrapped,
  conmon, # Container runtime monitor
  crun, # Container runtime (default with cgroups v2 for podman/buildah)
  fuse-overlayfs, # CoW for images, much faster than default vfs
  iptables,
  makeBinaryWrapper,
  netavark,
  passt,
  runCommand,
  runc, # Default container runtime
  slirp4netns, # User-mode networking for unprivileged namespaces
  symlinkJoin,
  util-linuxMinimal, # nsenter
  extraPackages ? [ ],
}:

let
  binPath = lib.makeBinPath (
    [
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      runc
      crun
      conmon
      slirp4netns
      fuse-overlayfs
      util-linuxMinimal
      iptables
    ]
    ++ extraPackages
  );

  helpersBin = symlinkJoin {
    name = "${buildah-unwrapped.pname}-helper-binary-wrapper-${buildah-unwrapped.version}";

    # this only works for some binaries, others may need to be added to `binPath` or in the modules
    paths = [
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      aardvark-dns
      netavark
      passt
    ];
  };

in
runCommand buildah-unwrapped.name
  {
    inherit (buildah-unwrapped) pname version passthru;

    outputs = [
      "out"
      "man"
    ];

    nativeBuildInputs = [
      makeBinaryWrapper
    ];

    name = "${buildah-unwrapped.pname}-wrapper-${buildah-unwrapped.version}";
    preferLocalBuild = true;
    meta = removeAttrs buildah-unwrapped.meta [ "outputsToInstall" ];

  }
  ''
    ln -s ${buildah-unwrapped.man} $man

    mkdir -p $out
    ln -s ${buildah-unwrapped}/share $out/share
    makeWrapper ${buildah-unwrapped}/bin/buildah $out/bin/buildah \
      --set CONTAINERS_HELPER_BINARY_DIR ${helpersBin}/bin \
      --prefix PATH : "${binPath}"
  ''
