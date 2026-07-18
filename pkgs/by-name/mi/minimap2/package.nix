{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "minimap2";
  version = "2.31";

  src = fetchFromGitHub {
    owner = "lh3";
    repo = "minimap2";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-RH9IvpmcDEnuFEXucORpzeWc+yJlAvW4r6RnaUT+//c=";
  };

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ zlib ];

  makeFlags =
    lib.optionals stdenv.hostPlatform.isAarch [ "arm_neon=1" ]
    ++ lib.optionals stdenv.hostPlatform.isAarch64 [ "aarch64=1" ];

  installPhase = ''
    runHook preInstall
    install -m755 -Dt $out/bin minimap2
    installManPage minimap2.1
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Versatile pairwise aligner for genomic and spliced nucleotide sequences";

    longDescription = ''
      Minimap2 is a versatile sequence alignment program that aligns
      DNA or mRNA sequences against a large reference database. It is
      particularly efficient for long reads and can handle various
      sequencing technologies including PacBio and Oxford Nanopore.
    '';

    homepage = "https://lh3.github.io/minimap2";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.arcadio ];
    platforms = lib.platforms.unix;
    mainProgram = "minimap2";
  };
})
