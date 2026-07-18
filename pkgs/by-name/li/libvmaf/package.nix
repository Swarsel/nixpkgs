{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  ffmpeg-full,
  libaom,
  meson,
  nasm,
  ninja,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libvmaf";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "netflix";
    repo = "vmaf";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-6mwU2so1YM2pyWkJbDHVl443GgWtQazbBv3gTMBq5NA=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isFreeBSD ''
    substituteInPlace meson.build --replace-fail '_XOPEN_SOURCE=600' '_XOPEN_SOURCE=700'
  '';

  nativeBuildInputs = [
    meson
    ninja
    nasm
    (buildPackages.callPackage ./xxd.nix { })
  ];

  mesonFlags = [ "-Denable_avx512=true" ];

  env = lib.optionalAttrs stdenv.hostPlatform.isFreeBSD {
    NIX_CFLAGS_COMPILE = "-D__BSD_VISIBLE=1";
  };

  doCheck = false;
  sourceRoot = "${finalAttrs.src.name}/libvmaf";

  passthru.tests = {
    inherit libaom ffmpeg-full;

    version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };

    pkg-config = testers.hasPkgConfigModules {
      moduleNames = [ "libvmaf" ];
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Perceptual video quality assessment based on multi-method fusion (VMAF)";
    homepage = "https://github.com/Netflix/vmaf";
    changelog = "https://github.com/Netflix/vmaf/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.bsd2Patent;
    maintainers = [ lib.maintainers.cfsmp3 ];
    platforms = lib.platforms.unix;
    mainProgram = "vmaf";
  };
})
