{
  lib,
  stdenv,
  fetchFromGitHub,
  android-tools,
  clang,
  dbus,
  expat,
  fontconfig,
  freetype,
  libglvnd,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeWrapper,
  mold,
  nix-update-script,
  pkg-config,
  rustPlatform,
  wayland,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "universal-android-debloater";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "Universal-Debloater-Alliance";
    repo = "universal-android-debloater-next-generation";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TGelOjwqTzYShZxXyPTTfkjAreFmZmrCF7jtp1UAfDw=";
  };

  nativeBuildInputs = [
    makeWrapper
    mold
    pkg-config
  ];

  buildInputs = [
    expat
    fontconfig
    freetype
  ];

  cargoHash = "sha256-RutiCWTkXnF7W86SnXRs+vI7dELrbdZXI62J8suZv5g=";

  nativeCheckInputs = [
    clang
    writableTmpDirAsHomeHook
  ];

  postInstall = ''
    wrapProgram $out/bin/uad-ng --prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath (
        [
          dbus
          fontconfig
          freetype
          libglvnd
          libxkbcommon
          libx11
          libxcursor
          libxi
          libxrandr
        ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [ wayland ]
      )
    } --suffix PATH : ${lib.makeBinPath [ android-tools ]}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool to debloat non-rooted Android devices";
    homepage = "https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation";
    changelog = "https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ lavafroth ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "uad-ng";
    broken = with stdenv.hostPlatform; isDarwin && isx86_64;
  };
})
