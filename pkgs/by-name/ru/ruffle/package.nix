{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  autoPatchelfHook,
  curl,
  jq,
  jre_minimal,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  nix-update,
  openh264,
  pkg-config,
  rustPlatform,
  udev,
  vulkan-loader,
  wayland,
  writeShellApplication,
  withRuffleTools ? false,
  withX11 ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ruffle";
  version = "0.2.0-nightly-2026-04-23";

  src = fetchFromGitHub {
    owner = "ruffle-rs";
    repo = "ruffle";
    tag = lib.strings.removePrefix "0.2.0-" finalAttrs.version;
    hash = "sha256-v8o5HbwL/nMcrKcJSFfO9EHeaIeCakHgmSpQSwEOO3I=";
  };

  postPatch =
    let
      versionList = lib.versions.splitVersion openh264.version;
      major = lib.elemAt versionList 0;
      minor = lib.elemAt versionList 1;
      patch = lib.elemAt versionList 2;
    in
    ''
      substituteInPlace video/external/src/decoder/openh264.rs \
        --replace-fail "OpenH264Version(2, 4, 1)" \
                       "OpenH264Version(${major}, ${minor}, ${patch})"
    '';

  nativeBuildInputs = [
    jre_minimal
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
    autoPatchelfHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ rustPlatform.bindgenHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    udev
    (lib.getLib stdenv.cc.cc)
  ];

  cargoHash = "sha256-wQ2rM0O9X7xLZsIwdMrIApdDd5nSaDFj+e1TZkSPptU=";

  env =
    let
      tag = lib.strings.removePrefix "0.2.0-" finalAttrs.version;
      versionDate = lib.strings.removePrefix "0.2.0-nightly-" finalAttrs.version;
    in
    {
      VERGEN_GIT_COMMIT_DATE = versionDate;
      VERGEN_GIT_COMMIT_TIMESTAMP = "${versionDate}T00:00:00Z";
      VERGEN_GIT_SHA = tag;
      VERGEN_IDEMPOTENT = "1";
    };

  postInstall = ''
    mv $out/bin/ruffle_desktop $out/bin/ruffle
    install -Dm644 LICENSE.md -t $out/share/doc/ruffle
    install -Dm644 README.md -t $out/share/doc/ruffle
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm644 desktop/packages/linux/rs.ruffle.Ruffle.desktop \
                   -t $out/share/applications/

    install -Dm644 desktop/packages/linux/rs.ruffle.Ruffle.svg \
                   -t $out/share/icons/hicolor/scalable/apps/

    install -Dm644 desktop/packages/linux/rs.ruffle.Ruffle.metainfo.xml \
                   -t $out/share/metainfo/
  '';

  cargoBuildFlags = lib.optional withRuffleTools "--workspace";

  runtimeDependencies = lib.optionals stdenv.hostPlatform.isLinux (
    [
      wayland
      libxkbcommon
      vulkan-loader
      openh264
    ]
    ++ lib.optionals withX11 [
      libxcursor
      libxrandr
      libxi
      libx11
      libxcb
    ]
  );

  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "ruffle-update";

      runtimeInputs = [
        curl
        jq
        nix-update
      ];

      text = ''
        version="$( \
          curl https://api.github.com/repos/ruffle-rs/ruffle/releases?per_page=1 | \
          jq -r ".[0].tag_name" \
        )"
        exec nix-update --version "0.2.0-$version" ruffle
      '';
    });
  };

  meta = {
    description = "Cross platform Adobe Flash Player emulator";

    longDescription = ''
      Ruffle is a cross platform emulator for running and preserving
      Adobe Flash content. It is capable of running ActionScript 1, 2
      and 3 programs with machine-native performance thanks to being
      written in the Rust programming language.

      Additionally, overriding the `withRuffleTools` input to
      `true` will build all the available packages in the ruffle
      project, including the `exporter` and `scanner` utilities.
    '';

    homepage = "https://ruffle.rs/";
    changelog = "https://github.com/ruffle-rs/ruffle/releases/tag/${lib.strings.removePrefix "0.2.0-" finalAttrs.version}";

    license = [
      lib.licenses.mit
      lib.licenses.asl20
    ];

    maintainers = [
      lib.maintainers.jchw
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "ruffle";
    downloadPage = "https://ruffle.rs/downloads";
  };
})
