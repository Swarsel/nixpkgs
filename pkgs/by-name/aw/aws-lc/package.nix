{
  lib,
  stdenv,
  fetchFromGitHub,
  aws-lc,
  cmakeMinimal,
  ninja,
  nix-update-script,
  rust-bindgen,
  testers,
  useSharedLibraries ? !stdenv.hostPlatform.isStatic,
  withRustBindings ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "aws-lc";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "aws-lc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Dvy6mzEfKgimxCGp7q2fPk9urBMJMU6gZmaZXwdZfWw=";
  };

  outputs = [
    "out"
    "bin"
    "dev"
  ];

  nativeBuildInputs = [
    cmakeMinimal
    ninja
  ]
  ++ lib.optionals withRustBindings [
    rust-bindgen
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" useSharedLibraries)
    (lib.cmakeBool "GENERATE_RUST_BINDINGS" withRustBindings)
    "-GNinja"
    "-DDISABLE_GO=ON"
    "-DDISABLE_PERL=ON"
    "-DBUILD_TESTING=ON"
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isGNU [
      # Needed with GCC 12 but breaks on darwin (with clang)
      "-Wno-error=stringop-overflow"
    ]
  );

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    ninja run_minimal_tests
    runHook postCheck
  '';

  postInstall = ''
    moveToOutput lib/crypto/cmake "$dev"
    moveToOutput lib/ssl/cmake "$dev"
  ''
  + lib.optionalString withRustBindings ''
    moveToOutput share/rust "$dev"
  '';

  __darwinAllowLocalNetworking = true;

  passthru = {
    tests = {
      version = testers.testVersion {
        command = "bssl version";
        package = aws-lc;
      };

      pkg-config = testers.hasPkgConfigModules {
        moduleNames = [
          "libcrypto"
          "libssl"
          "openssl"
        ];

        package = aws-lc;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "General-purpose cryptographic library maintained by the AWS Cryptography team for AWS and their customers";
    homepage = "https://github.com/aws/aws-lc";

    license = [
      lib.licenses.asl20 # or
      lib.licenses.isc
    ];

    maintainers = [ lib.maintainers.theoparis ];
    platforms = lib.platforms.unix;
    mainProgram = "bssl";
  };
})
