{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
}:

let
  KDIR = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
in
stdenv.mkDerivation {
  pname = "amdgpu-i2c";
  version = "0-unstable-2024-12-16";

  src = fetchFromGitHub {
    owner = "twifty";
    repo = "amd-gpu-i2c";
    rev = "06ca41fd12fb90f970d3ebd4785cc26cc0a3f3b0";
    sha256 = "sha256-GVyrwnwNSBW4OCNDqQMU6e31C4bG14arC0MPkRWfiJQ=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;
  buildPhase = "make -C ${KDIR} M=/build/source modules";

  installPhase = ''
    make -C ${KDIR} M=/build/source INSTALL_MOD_PATH="$out" modules_install
  '';

  hardeningDisable = [ "pic" ];

  meta = {
    description = "Exposes i2c interface to set colors on AMD GPUs";
    homepage = "https://github.com/twifty/amd-gpu-i2c";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ thardin ];
    platforms = lib.platforms.linux;
    broken = kernel.kernelOlder "6.1.0";
    downloadPage = "https://github.com/twifty/amd-gpu-i2c";
  };
}
