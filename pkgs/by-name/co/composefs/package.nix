{
  lib,
  stdenv,
  fetchFromGitHub,
  erofs-utils,
  fetchpatch,
  fsverity-utils,
  fuse3,
  go-md2man,
  libcap,
  meson,
  ninja,
  nix-update-script,
  nixosTests,
  openssl,
  pkg-config,
  python3,
  testers,
  valgrind,
  which,
  enableValgrindCheck ? false,
  fuseSupport ? lib.meta.availableOn stdenv.hostPlatform fuse3,
  installExperimentalTools ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "composefs";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "composefs";
    repo = "composefs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nuQ3R/0eDS58HmN+0iXcYT5EtkY3J257EdtLir5vm4c=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  patches = [
    # "tests: ignore EOPNOTSUPP in in fsverity tests" https://github.com/composefs/composefs/pull/415
    (fetchpatch {
      hash = "sha256-nzUENLM24G6NezhPywVsRzRgWmL1VZdMfZTsXNorJl8=";
      url = "https://github.com/composefs/composefs/commit/b3cb176a771386081c993e29ae42e77dabe5a577.patch";
    })
  ];

  postPatch =
    # 'both_libraries' as an install target always builds both versions.
    #  This results in double disk usage for normal builds and broken static builds,
    #  so we replace it with the regular library target.
    ''
      substituteInPlace libcomposefs/meson.build \
        --replace-fail "both_libraries" "library"
    ''
    + lib.optionalString installExperimentalTools ''
      substituteInPlace tools/meson.build \
        --replace-fail "install : false" "install : true"
    '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    go-md2man
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optional fuseSupport fuse3
  ++ lib.filter (lib.meta.availableOn stdenv.hostPlatform) [
    libcap
  ];

  doCheck = true;

  nativeCheckInputs = [
    python3
    which
  ]
  ++ lib.optional enableValgrindCheck valgrind
  ++ lib.optional fuseSupport fuse3
  ++ lib.filter (lib.meta.availableOn stdenv.buildPlatform) [
    erofs-utils
    fsverity-utils
  ];

  preCheck = ''
    patchShebangs --build ../tests/*dir ../tests/*.sh
  '';

  mesonCheckFlags = lib.optionals enableValgrindCheck "--setup=valgrind";

  passthru = {
    tests = {
      # Broken on aarch64 unrelated to this package: https://github.com/NixOS/nixpkgs/issues/291398
      inherit (nixosTests) activation-etc-overlay-immutable activation-etc-overlay-mutable;
      pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "File system for mounting container images";
    homepage = "https://github.com/composefs/composefs";
    changelog = "https://github.com/composefs/composefs/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      gpl2Only
      asl20
    ];

    maintainers = with lib.maintainers; [ kiskae ];
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.darwin;
    mainProgram = "mkcomposefs";
    pkgConfigModules = [ "composefs" ];
  };
})
