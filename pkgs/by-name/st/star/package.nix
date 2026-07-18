{
  lib,
  stdenv,
  fetchFromGitHub,
  llvmPackages,
  nix-update-script,
  versionCheckHook,
  xxd,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "star";
  version = "2.7.11b";

  src = fetchFromGitHub {
    owner = "alexdobin";
    repo = "STAR";
    rev = finalAttrs.version;
    sha256 = "sha256-4EoS9NOKUwfr6TDdjAqr4wGS9cqVX5GYptiOCQpmg9c=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace-fail "-std=c++11" "-std=c++14"
  '';

  nativeBuildInputs = [ xxd ];
  buildInputs = [ zlib ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ llvmPackages.openmp ];
  makeFlags = lib.optionals stdenv.hostPlatform.isAarch64 [ "CXXFLAGS_SIMD=" ];

  buildFlags = [
    "STAR"
    "STARlong"
  ];

  preBuild = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export CXXFLAGS="$CXXFLAGS -DSHM_NORESERVE=0"
  '';

  installPhase = ''
    runHook preInstall
    install -D STAR STARlong -t $out/bin
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  enableParallelBuilding = true;
  sourceRoot = "${finalAttrs.src.name}/source";
  versionCheckProgram = "${placeholder "out"}/bin/STAR";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Spliced Transcripts Alignment to a Reference";

    longDescription = ''
      STAR (Spliced Transcripts Alignment to a Reference) is a fast RNA-seq
      read mapper, with support for splice-junction and fusion read detection.
    '';

    homepage = "https://github.com/alexdobin/STAR";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.arcadio ];
    platforms = lib.platforms.unix;
    mainProgram = "STAR";
  };
})
