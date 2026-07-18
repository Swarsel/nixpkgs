{
  lib,
  stdenv,
  kernel,
  mdio-tools,
}:

stdenv.mkDerivation {
  inherit (mdio-tools) src;
  pname = "mdio-netlink";
  version = "${mdio-tools.version}-${kernel.version}";
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.commonMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=${placeholder "out"}"
  ];

  sourceRoot = "source/kernel";

  meta = {
    description = "Netlink support for MDIO devices";
    homepage = "https://github.com/wkz/mdio-tools";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.jmbaur ];
    platforms = lib.platforms.linux;
  };
}
