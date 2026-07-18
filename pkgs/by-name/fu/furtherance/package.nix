{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxscrnsaver,
  openssl,
  pkg-config,
  rustPlatform,
  vulkan-loader,
  wayland,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "furtherance";
  version = "26.7.0";

  src = fetchFromGitHub {
    owner = "unobserved-io";
    repo = "Furtherance";
    rev = finalAttrs.version;
    hash = "sha256-UMkFEbLdwZsSJviO29FNmLYLL5/HofhriMptpjSAYuY=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    fontconfig
    openssl
    libxkbcommon
    libx11
    libxscrnsaver
    libxcursor
    libxi
    vulkan-loader
    wayland
  ];

  cargoHash = "sha256-fdslQutVEGq1EG+Q8QAYKf9XfoostvHKWZrr4YwEowQ=";

  checkFlags = [
    # panicked at src/tests/timer_tests.rs:30:9
    "--skip=tests::timer_tests::timer_tests::test_split_task_input_basic"
  ];

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf $out/bin/${finalAttrs.meta.mainProgram} \
      --add-rpath ${
        lib.makeLibraryPath [
          vulkan-loader
          libxkbcommon
          wayland
        ]
      }
  '';

  meta = {
    description = "Track your time without being tracked";
    homepage = "https://github.com/unobserved-io/Furtherance";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      CaptainJawZ
      locnide
    ];

    platforms = lib.platforms.linux;
    mainProgram = "furtherance";
  };
})
