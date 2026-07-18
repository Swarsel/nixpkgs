{
  lib,
  conmon, # Container runtime monitor
  conntrack-tools,
  cri-o-unwrapped,
  crun, # Container runtime (default with cgroups v2 for podman/buildah)
  iptables,
  makeWrapper,
  runCommand,
  runc, # Default container runtime
  util-linux, # nsenter
  extraPackages ? [ ],
}:

let
  binPath = lib.makeBinPath (
    [
      runc
      conntrack-tools
      crun
      conmon
      util-linux
      iptables
    ]
    ++ extraPackages
  );

in
runCommand cri-o-unwrapped.name
  {
    inherit (cri-o-unwrapped) pname version passthru;

    outputs = [
      "out"
      "man"
    ];

    nativeBuildInputs = [
      makeWrapper
    ];

    name = "${cri-o-unwrapped.pname}-wrapper-${cri-o-unwrapped.version}";
    preferLocalBuild = true;
    meta = removeAttrs cri-o-unwrapped.meta [ "outputsToInstall" ];

  }
  ''
    ln -s ${cri-o-unwrapped.man} $man

    mkdir -p $out/bin
    ln -s ${cri-o-unwrapped}/etc $out/etc
    ln -s ${cri-o-unwrapped}/share $out/share

    for p in ${cri-o-unwrapped}/bin/*; do
      makeWrapper $p $out/bin/''${p##*/} \
        --prefix PATH : ${binPath}
    done
  ''
