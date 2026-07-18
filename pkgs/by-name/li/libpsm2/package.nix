{
  lib,
  stdenv,
  fetchFromGitHub,
  numactl,
  pkg-config,
  udevCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libpsm2";
  version = "12.0.1";

  src = fetchFromGitHub {
    owner = "cornelisnetworks";
    repo = "opa-psm2";
    rev = "PSM2_${finalAttrs.version}";
    sha256 = "sha256-MzocxY+X2a5rJvTo+gFU0U10YzzazR1IxzgEporJyhI=";
  };

  nativeBuildInputs = [
    pkg-config
    udevCheckHook
  ];

  buildInputs = [ numactl ];

  makeFlags = [
    # Disable blanket -Werror to avoid build failures
    # on fresh toolchains like gcc-11.
    "WERROR="
  ];

  preConfigure = ''
    export UDEVDIR=$out/etc/udev
    substituteInPlace ./Makefile --replace "udevrulesdir}" "prefix}/etc/udev";
  '';

  postInstall = ''
    mv $out/usr/* $out
    rmdir $out/usr
  '';

  doInstallCheck = true;
  enableParallelBuilding = true;

  installFlags = [
    "DESTDIR=$(out)"
    "UDEVDIR=/etc/udev"
    "LIBPSM2_COMPAT_CONF_DIR=/etc"
  ];

  meta = {
    description = "PSM2 library supports a number of fabric media and stacks";
    homepage = "https://github.com/cornelisnetworks/opa-psm2";

    license = with lib.licenses; [
      gpl2Only
      bsd3
    ];

    maintainers = [ lib.maintainers.bzizou ];
    platforms = [ "x86_64-linux" ];
    # uses __off64_t, srand48_r, lrand48_r, drand48_r
    broken = stdenv.hostPlatform.isMusl;
  };
})
