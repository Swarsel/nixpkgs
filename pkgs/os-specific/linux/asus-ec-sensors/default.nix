{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation rec {
  pname = "asus-ec-sensors";
  version = "0.1.0-unstable-2025-12-11";

  src = fetchFromGitHub {
    owner = "zeule";
    repo = "asus-ec-sensors";
    rev = "0e73cd165c4d1baf8ce841604722c6981b7ba9d6";
    sha256 = "sha256-qX+HmtBdm9bOJRnlpI/Ru0OCcUi8MQ29Y731yM9JEi0=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
  ];

  installPhase = ''
    install asus-ec-sensors.ko -Dm444 -t ${placeholder "out"}/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon
  '';

  hardeningDisable = [ "pic" ];
  name = "${pname}-${version}-${kernel.version}";

  meta = {
    description = "Linux HWMON sensors driver for ASUS motherboards to read sensor data from the embedded controller";
    homepage = "https://github.com/zeule/asus-ec-sensors";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      nickhu
      mariolopjr
    ];

    platforms = [ "x86_64-linux" ];
    broken = kernel.kernelOlder "5.11";
  };
}
