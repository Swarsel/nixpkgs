{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  freetype,
  gumbo,
  harfbuzz,
  jbig2dec,
  just,
  lcms2,
  leptonica,
  libcosmicAppHook,
  libjpeg,
  nix-update-script,
  openjpeg,
  rustPlatform,
  tesseract,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-reader";
  version = "0-unstable-2026-06-06";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-reader";
    rev = "31485419db10e12c2942029d673836343e4609dd";
    hash = "sha256-XZ5A7Qi+sxlUel1Fpr9wy8o0MD9mtyqFIwBN4Rf7CcU=";
  };

  nativeBuildInputs = [
    just
    libcosmicAppHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    fontconfig
    freetype
    gumbo
    harfbuzz
    jbig2dec
    lcms2
    leptonica
    libjpeg
    openjpeg
    tesseract
  ];

  cargoHash = "sha256-DPGpGWzAgdpHp3qzksLtLnfqk+DJsaukdT2ekFFiGaM=";
  env.VERGEN_GIT_SHA = finalAttrs.src.rev;

  postInstall = ''
    substituteInPlace $out/share/thumbnailers/com.system76.CosmicReader.thumbnailer \
      --replace-fail "TryExec=cosmic-reader" "TryExec=$out/bin/cosmic-reader" \
      --replace-fail "Exec=cosmic-reader" "Exec=$out/bin/cosmic-reader"
  '';

  __structuredAttrs = true;
  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  separateDebugInfo = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch=HEAD"
    ];
  };

  meta = {
    description = "PDF reader for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-reader";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-reader";
    teams = [ lib.teams.cosmic ];
  };
})
