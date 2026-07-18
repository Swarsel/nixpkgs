{
  lib,
  stdenv,
  fetchFromGitHub,
  atk,
  cairo,
  callPackage,
  fontconfig,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gtk4,
  libglvnd,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  pango,
  pkg-config,
  rustPlatform,
  testers,
  versionCheckHook,
  wayland,
  wrapGAppsHook4,
  xvfb-run,
}:

let
  self = rustPlatform.buildRustPackage {
    pname = "czkawka";
    version = "12.0.0";

    src = fetchFromGitHub {
      owner = "qarmin";
      repo = "czkawka";
      tag = self.version;
      hash = "sha256-KbGcaeQcpf2IL3I2PmsBpg8n+IfSuJl5tkLOxNCtYaQ=";
    };

    strictDeps = true;

    nativeBuildInputs = [
      gobject-introspection
      pkg-config
      wrapGAppsHook4
    ];

    buildInputs = [
      atk
      cairo
      fontconfig
      gdk-pixbuf
      glib
      gtk4
      pango
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      libglvnd
      libxkbcommon
      wayland
    ];

    cargoHash = "sha256-+1K2a64XcbBePiQ/LeaSVCU/Ih0Fr4EjzNU5xpzfz2Q=";
    doCheck = stdenv.hostPlatform.isLinux && (stdenv.hostPlatform == stdenv.buildPlatform);
    nativeCheckInputs = [ xvfb-run ];

    checkPhase = ''
      runHook preCheck
      xvfb-run cargo test
      runHook postCheck
    '';

    # Desktop items, icons and metainfo are not installed automatically
    postInstall = ''
      # Czkawka
      install -Dm444 -t $out/share/applications data/com.github.qarmin.czkawka.desktop
      install -Dm444 -t $out/share/icons/hicolor/scalable/apps data/icons/com.github.qarmin.czkawka.svg
      install -Dm444 -t $out/share/icons/hicolor/scalable/apps data/icons/com.github.qarmin.czkawka-symbolic.svg
      install -Dm444 -t $out/share/metainfo data/com.github.qarmin.czkawka.metainfo.xml

      # Krokiet
      install -Dm444 -t $out/share/applications data/io.github.qarmin.krokiet.desktop
      install -Dm444 -t $out/share/icons/hicolor/scalable/apps data/icons/io.github.qarmin.krokiet.svg
      install -Dm444 -t $out/share/metainfo data/io.github.qarmin.krokiet.metainfo.xml
    '';

    doInstallCheck = true;

    nativeInstallCheckInputs = [
      versionCheckHook
    ];

    postFixup = ''
      wrapGApp $out/bin/czkawka_gui
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      patchelf --add-rpath "${
        lib.makeLibraryPath [
          fontconfig
          libglvnd
          libx11
          libxcursor
          libxi
          libxrandr
          libxkbcommon
          wayland
        ]
      }" $out/bin/krokiet
    '';

    dontWrapGApps = true;
    versionCheckProgram = "${placeholder "out"}/bin/czkawka_cli";

    passthru = {
      tests.version = testers.testVersion {
        command = "czkawka_cli --version";
        package = self;
      };

      wrapper = callPackage ./wrapper.nix {
        czkawka = self;
      };
    };

    meta = {
      description = "Simple, fast and easy to use app to remove unnecessary files from your computer";
      homepage = "https://github.com/qarmin/czkawka";
      changelog = "https://github.com/qarmin/czkawka/raw/${self.version}/Changelog.md";
      license = with lib.licenses; [ mit ];

      maintainers = with lib.maintainers; [
        yanganto
        _0x4A6F
      ];

      mainProgram = "czkawka_gui";
    };
  };
in
self
