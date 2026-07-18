{
  lib,
  fetchFromGitHub,
  buildGoModule,
  clang,
  nix-update-script,
  nixosTests,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "dae";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = "dae";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hzX3b86BHvxXQZotSteiHoyBMF/P4WubeuJ6xpxa8ac=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ clang ];
  vendorHash = "sha256-S2dNFvMeZqGhzu+sIBGeaET4bQXfeucao6XR4QSTpog=";

  buildPhase = ''
    runHook preBuild

    make CFLAGS="-D__REMOVE_BPF_PRINTK -fno-stack-protector -Wno-unused-command-line-argument" \
    NOSTRIP=y \
    VERSION=${finalAttrs.version} \
    OUTPUT=$out/bin/dae

    runHook postBuild
  '';

  # network required
  doCheck = false;

  postInstall = ''
    install -Dm444 install/dae.service $out/lib/systemd/system/dae.service
    substituteInPlace $out/lib/systemd/system/dae.service \
      --replace-fail "/usr/bin/dae" "$out/bin/dae"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  hardeningDisable = [
    "zerocallusedregs"
  ];

  proxyVendor = true;

  passthru = {
    tests = {
      inherit (nixosTests) dae;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Linux high-performance transparent proxy solution based on eBPF";
    homepage = "https://github.com/daeuniverse/dae";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      oluceps
      pokon548
      luochen1990
    ];

    platforms = lib.platforms.linux;
    mainProgram = "dae";
  };
})
