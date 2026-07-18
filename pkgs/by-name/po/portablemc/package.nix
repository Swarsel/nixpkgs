{
  lib,
  stdenv,
  fetchFromGitHub,
  addDriverRunpath,
  alsa-lib,
  flite,
  glfw3-minecraft,
  jdk17,
  jdk21,
  jdk25,
  jdk8,
  libGL,
  libjack2,
  libpulseaudio,
  libx11,
  libxcursor,
  libxext,
  libxrandr,
  libxxf86vm,
  makeWrapper,
  openal,
  openssl,
  pciutils,
  pipewire,
  pkg-config,
  rustPlatform,
  udev,
  vulkan-loader,
  xrandr,
  additionalLibs ? [ ],
  additionalPrograms ? [ ],
  # can be overriden to reduce the closure size
  jvms ? [
    jdk25
    jdk21
    jdk17
    jdk8
  ],
  textToSpeechSupport ? stdenv.hostPlatform.isLinux,
}:

let
  # Copied from the `prismlauncher` package
  runtimeLibs = [
    (lib.getLib stdenv.cc.cc)
    ## native versions
    glfw3-minecraft
    openal

    ## openal
    alsa-lib
    libjack2
    libpulseaudio
    pipewire

    ## glfw
    libGL
    libx11
    libxcursor
    libxext
    libxrandr
    libxxf86vm

    udev # oshi

    vulkan-loader # VulkanMod's lwjgl
  ]
  ++ lib.optional textToSpeechSupport flite
  ++ additionalLibs;

  # Copied from the `prismlauncher` package
  runtimePrograms = [
    pciutils # need lspci
    xrandr # needed for LWJGL [2.9.2, 3) https://github.com/LWJGL/lwjgl/issues/128
  ]
  ++ additionalPrograms;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "portablemc";
  version = "5.0.3";

  src = fetchFromGitHub {
    owner = "theorzr";
    repo = "portablemc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-P/ah7pwOdbgRDgpvhEDcNA1RiDzG2nYZCR13vzljLd8=";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    makeWrapper "$unwrapped/bin/portablemc" "$out/bin/portablemc" \
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        --prefix LD_LIBRARY_PATH : "${addDriverRunpath.driverLink}/lib:${lib.makeLibraryPath runtimeLibs}" \
        --prefix PATH : "${lib.makeBinPath runtimePrograms}" \
      ''} \
      --prefix PATH : ${lib.makeBinPath jvms}

    runHook postInstall
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-Ub9XVc6gcu6fEiOheew9Uh3LqdaSzVKITboDTK+MQUI=";
  };

  dontUnpack = true;

  unwrapped = rustPlatform.buildRustPackage {
    inherit (finalAttrs) src cargoDeps;
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ openssl ];
    name = "portablemc-${finalAttrs.version}-unwrapped";
  };

  meta = {
    description = "Cross platform command line utility for launching Minecraft quickly and reliably with included support for Mojang versions and popular mod loaders";
    homepage = "https://github.com/theorzr/portablemc";
    changelog = "https://github.com/theorzr/portablemc/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "portablemc";
  };
})
