{
  stdenv,
  kernel,
  virtualbox,
}:

stdenv.mkDerivation {
  pname = "virtualbox-modules";
  version = "${virtualbox.version}-${kernel.version}";
  src = virtualbox.modsrc;
  nativeBuildInputs = kernel.moduleBuildDependencies;
  makeFlags = [ "INSTALL_MOD_PATH=$(out)" ];
  env.KERN_DIR = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  enableParallelBuilding = true;

  hardeningDisable = [
    "fortify"
    "pic"
    "stackprotector"
  ];

  installTargets = [ "install" ];

  meta = virtualbox.meta // {
    description = virtualbox.meta.description + " (kernel modules)";
  };
}
