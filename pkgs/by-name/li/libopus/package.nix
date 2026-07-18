{
  lib,
  stdenv,
  fetchurl,
  # tests
  ffmpeg-headless,
  gitUpdater,
  meson,
  ninja,
  python3,
  testers,
  fixedPoint ? false,
  withAsm ? false,
  withCustomModes ? true,
  withIntrinsics ? stdenv.hostPlatform.isAarch || stdenv.hostPlatform.isx86,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libopus";
  version = "1.6.1";

  src = fetchurl {
    url = "https://downloads.xiph.org/releases/opus/opus-${finalAttrs.version}.tar.gz";
    hash = "sha256-b/y1kyB76SWE3xWzJGbtZLvsmRCfAHyCIF8BlFckEaE=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Some tests time out easily on slower machines
    ./test-timeout.patch
  ];

  postPatch = ''
    patchShebangs meson/
  '';

  nativeBuildInputs = [
    meson
    python3
    ninja
  ];

  mesonFlags = [
    (lib.mesonBool "fixed-point" fixedPoint)
    (lib.mesonBool "custom-modes" withCustomModes)
    (lib.mesonEnable "intrinsics" withIntrinsics)
    (lib.mesonEnable "rtcd" (withIntrinsics || withAsm))
    (lib.mesonEnable "asm" withAsm)
    (lib.mesonEnable "docs" false)
  ];

  doCheck = !stdenv.hostPlatform.isi686 && !stdenv.hostPlatform.isAarch32; # test_unit_LPC_inv_pred_gain fails

  passthru = {
    tests = {
      inherit ffmpeg-headless;

      pkg-config = testers.hasPkgConfigModules {
        moduleNames = [ "opus" ];
        package = finalAttrs.finalPackage;
      };
    };

    updateScript = gitUpdater {
      rev-prefix = "v";
      url = "https://gitlab.xiph.org/xiph/opus.git";
    };
  };

  meta = {
    description = "Open, royalty-free, highly versatile audio codec";
    homepage = "https://opus-codec.org/";
    changelog = "https://gitlab.xiph.org/xiph/opus/-/releases/v${finalAttrs.version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      getchoo
      jopejoe1
    ];

    platforms = lib.platforms.all;
  };
})
