{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  dotool,
  libGL,
  libpulseaudio,
  libx11,
  libxcursor,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxxf86vm,
  makeWrapper,
  nix-update-script,
  pkg-config,
  testers,
  wayland,
}:

buildGoModule (finalAttrs: {
  pname = "voxinput";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "richiejp";
    repo = "VoxInput";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zb3tz8YuS2VJWXbr8+yBuL89vlDXadFowSzWuZ5a0WI=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    libpulseaudio
    dotool

    libGL
    libx11.dev
    libxcursor
    libxi
    libxinerama
    libxrandr
    libxxf86vm
    libxkbcommon
    wayland
  ];

  vendorHash = "sha256-NMuHvhN1A6TQ18Z1H8k8Sy7Py9744Xv95MZz0QvExQY=";

  # To take advantage of the udev rule something like `services.udev.packages = [ nixpkgs.voxinput ]`
  # needs to be added to your configuration.nix
  postInstall = ''
    mv $out/bin/VoxInput $out/bin/voxinput_tmp ; mv $out/bin/voxinput_tmp $out/bin/voxinput
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/voxinput \
      --prefix PATH : ${lib.makeBinPath [ dotool ]}
    mkdir -p $out/lib/udev/rules.d
    echo 'KERNEL=="uinput", GROUP="input", MODE="0620", OPTIONS+="static_node=uinput"' > $out/lib/udev/rules.d/99-voxinput.rules
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isElf ''
    patchelf $out/bin/.voxinput-wrapped \
      --add-rpath ${lib.makeLibraryPath [ libpulseaudio ]}
  '';

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      command = "voxinput ver";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Voice to text for any Linux app via dotool/uinput and the LocalAI/OpenAI transcription API";
    homepage = "https://github.com/richiejp/VoxInput";
    changelog = "https://github.com/richiejp/VoxInput/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.richiejp ];
    platforms = lib.platforms.unix;
    mainProgram = "voxinput";
  };
})
