{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  clang,
  cmake,
  dotool,
  gitMinimal,
  installShellFiles,
  libclang,
  libnotify,
  makeBinaryWrapper,
  nix-update-script,
  onnxruntime,
  openssl,
  pciutils,
  pkg-config,
  rustPlatform,
  shaderc,
  versionCheckHook,
  vulkan-headers,
  vulkan-loader,
  which,
  wl-clipboard,
  wtype,
  xclip,
  xdotool,
  installManPages ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
  installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
  onnxSupport ? false,
  vulkanSupport ? false,
  waylandRuntimePackages ? [
    dotool
    wl-clipboard
    wtype
  ],
  waylandSupport ? stdenv.hostPlatform.isLinux,
  x11RuntimePackages ? [
    xclip
    xdotool
  ],
  x11Support ? stdenv.hostPlatform.isLinux,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "voxtype";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "peteonrails";
    repo = "voxtype";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CpG/5ws9VX8ZQjwtJMxyUF0L90u+j0veHHLHGqTvoIw=";
  };

  nativeBuildInputs = [
    cmake
    clang
    gitMinimal # Required by whisper.cpp cmake
    installShellFiles
    makeBinaryWrapper
    pkg-config
  ]
  ++ lib.optionals vulkanSupport [
    shaderc
    vulkan-headers
    vulkan-loader
  ];

  buildInputs = [
    alsa-lib
    openssl
  ]
  ++ lib.optionals vulkanSupport [
    vulkan-headers
    vulkan-loader
  ]
  ++ lib.optionals onnxSupport [
    onnxruntime
  ];

  cargoHash = "sha256-gHnYssFZixWt7F8oa1yYyfqThCrRsv0U7ezgZUcq1nk=";

  env = {
    # NOTE: set LIBCLANG_PATH so bindgen can locate libclang
    LIBCLANG_PATH = "${lib.getLib libclang}/lib";

    # NOTE: Ensure reproducible builds targeting AVX2-capable CPUs (x86-64-v3)
    # This matches the portable AVX2 binaries we ship for other distros
    RUSTFLAGS = lib.optionalString (
      stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64
    ) "-C target-cpu=x86-64-v3";
  };

  preBuild = ''
    # NOTE: whisper.cpp cmake needs some help in sandbox
    export CMAKE_BUILD_PARALLEL_LEVEL=$NIX_BUILD_CORES
  ''
  + lib.optionalString vulkanSupport ''
    export VULKAN_SDK="${shaderc.bin}"
  ''
  + lib.optionalString onnxSupport ''
    export ORT_LIB_LOCATION="${lib.getLib onnxruntime}/lib"
  '';

  postInstall = ''
    install -Dm644 config/default.toml \
      $out/share/voxtype/default-config.toml

    wrapProgram $out/bin/voxtype \
      --prefix PATH : ${
        (lib.makeBinPath (
          [
            libnotify
            which
          ]
          ++ lib.optionals vulkanSupport [
            pciutils
          ]
          ++ lib.optionals waylandSupport waylandRuntimePackages
          ++ lib.optionals x11Support x11RuntimePackages
        ))
        + lib.optionalString onnxSupport " \\"
      }
      ${lib.optionalString onnxSupport ''
        --set ORT_DYLIB_PATH "${lib.getLib onnxruntime}/lib/libonnxruntime.so" \
        --prefix LD_LIBRARY_PATH : "${lib.getLib onnxruntime}/lib"
      ''}
  ''
  + lib.optionalString installManPages ''
    installManPage target/debug/build/voxtype-*/out/man/*
  ''
  + lib.optionalString installShellCompletions ''
    installShellCompletion packaging/completions/voxtype.{bash,zsh,fish}
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  buildFeatures =
    [ ]
    ++ lib.optionals vulkanSupport [ "gpu-vulkan" ]
    ++ lib.optionals onnxSupport [
      "parakeet-load-dynamic"
      "moonshine"
      "sensevoice"
      "paraformer"
      "dolphin"
      "omnilingual"
    ];

  passthru.update-script = nix-update-script { };

  meta = {
    description = "Voice-to-text with push-to-talk for Wayland compositors";

    longDescription = ''
      Voxtype is a push-to-talk voice-to-text daemon for Linux.
      Hold a hotkey while speaking, release to transcribe and output
      text at your cursor position. Supports Whisper, Parakeet,
      SenseVoice, Moonshine, Paraformer, Dolphin, and Omnilingual engines.
    '';

    homepage = "https://voxtype.io";
    changelog = "https://github.com/peteonrails/voxtype/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ DuskyElf ];
    platforms = lib.platforms.linux;
    mainProgram = "voxtype";
    downloadPage = "https://voxtype.io/download/";
  };
})
