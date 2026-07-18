{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk_15,
  autoAddDriverRunpath,
  cmake,
  config,
  nix-update-script,
  removeReferencesTo,
  rocmPackages,
  versionCheckHook,
  cudaSupport ? config.cudaSupport,
  rocmSupport ? config.rocmSupport,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "btop";
  version = "1.4.7";

  src = fetchFromGitHub {
    owner = "aristocratos";
    repo = "btop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3gECGBSWcGTYQkUlD4X2zrxZVvH2x2xfh5zdZ2jJbDQ=";
  };

  nativeBuildInputs = [
    cmake
  ]
  ++ lib.optionals cudaSupport [
    autoAddDriverRunpath
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_15
  ];

  # fix build on darwin (see https://github.com/NixOS/nixpkgs/pull/422218#issuecomment-3039181870 and https://github.com/aristocratos/btop/pull/1173)
  cmakeFlags = [
    (lib.cmakeBool "BTOP_LTO" (!stdenv.hostPlatform.isDarwin))
    (lib.cmakeBool "BTOP_STATIC" (stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "BTOP_FORTIFY" (!stdenv.hostPlatform.isStatic))
  ];

  postInstall = ''
    ${removeReferencesTo}/bin/remove-references-to -t ${stdenv.cc.cc} $(readlink -f $out/bin/btop)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  hardeningDisable = lib.optionals stdenv.hostPlatform.isStatic [ "fortify" ];
  installFlags = [ "PREFIX=$(out)" ];

  postPatchelf = lib.optionalString rocmSupport ''
    patchelf --add-rpath ${lib.getLib rocmPackages.rocm-smi}/lib $out/bin/btop
  '';

  postPhases = lib.optionals rocmSupport [ "postPatchelf" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Monitor of resources";
    homepage = "https://github.com/aristocratos/btop";
    changelog = "https://github.com/aristocratos/btop/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      khaneliman
      rmcgibbo
      ryan4yin
      sigmasquadron
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "btop";
  };
})
