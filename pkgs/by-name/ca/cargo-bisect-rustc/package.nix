{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  patchelf,
  pkg-config,
  runCommand,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-bisect-rustc";
  version = "0.6.11";

  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = "cargo-bisect-rustc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uyIdQn9EQnjBAHBPqvphaKg2KRufveOXOiHEKk0fTGQ=";
  };

  patches =
    let
      patchelfPatch =
        runCommand "0001-dynamically-patchelf-binaries.patch"
          {
            CC = stdenv.cc;
            libPath = "$ORIGIN/../lib:${lib.makeLibraryPath [ zlib ]}";
            patchelf = patchelf;
          }
          ''
            export dynamicLinker=$(cat $CC/nix-support/dynamic-linker)
            substitute ${./0001-dynamically-patchelf-binaries.patch} $out \
              --subst-var patchelf \
              --subst-var dynamicLinker \
              --subst-var libPath
          '';
    in
    lib.optionals stdenv.hostPlatform.isLinux [ patchelfPatch ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-WSO5LvdJkAorSwsICz9NAWKNM7x4aeNvhGLhJSO6Vi8=";

  checkFlags = [
    "--skip=test_github" # requires internet
    "--skip=cli_tests" # trycmd does not seem to work in nix's sandbox
  ];

  __structuredAttrs = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Bisects rustc, either nightlies or CI artifacts";
    homepage = "https://github.com/rust-lang/cargo-bisect-rustc";

    license =
      with lib.licenses;
      OR [
        asl20
        mit
      ];

    maintainers = with lib.maintainers; [ sandarukasa ];
    mainProgram = "cargo-bisect-rustc";
  };
})
