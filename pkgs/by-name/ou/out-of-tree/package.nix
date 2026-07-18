{
  lib,
  buildGoModule,
  fetchgit,
  makeWrapper,
  podman,
  qemu,
}:

buildGoModule (finalAttrs: {
  pname = "out-of-tree";
  version = "2.1.1";

  src = fetchgit {
    url = "https://code.dumpstack.io/tools/out-of-tree.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XzO8NU7A5m631PjAm0F/K7qLrD+ZDSdHXaNowGaZAPo=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-p1dqzng3ak9lrnzrEABhE1TP1lM2Ikc8bmvp5L3nUp0=";
  doCheck = false;

  postFixup = ''
    wrapProgram $out/bin/out-of-tree \
      --prefix PATH : "${
        lib.makeBinPath [
          qemu
          podman
        ]
      }"
  '';

  meta = {
    description = "Kernel {module, exploit} development tool";
    homepage = "https://out-of-tree.io";
    license = lib.licenses.agpl3Plus;
    maintainers = [ lib.maintainers.dump_stack ];
    mainProgram = "out-of-tree";
  };
})
