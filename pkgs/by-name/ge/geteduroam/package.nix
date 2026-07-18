{
  lib,
  fetchFromGitHub,
  buildGoModule,
  cairo,
  gdk-pixbuf,
  glib,
  graphene,
  gtk4,
  libadwaita,
  makeWrapper,
  pango,
  symlinkJoin,
  versionCheckHook,
  wrapGAppsHook4,
}:

buildGoModule (finalAttrs: {
  pname = "geteduroam";
  version = "0.14";

  src = fetchFromGitHub {
    owner = "geteduroam";
    repo = "linux-app";
    tag = finalAttrs.version;
    hash = "sha256-Zvyba8ma4a5WmV6rnfUKqQ8AsZlGGWrZsL8UZIWApTQ=";
  };

  nativeBuildInputs = [
    wrapGAppsHook4
    makeWrapper
  ];

  vendorHash = "sha256-HYJ71pk1a8EaPycmbHmMnQeb42dt7M9NvK/1GYhZE0c=";

  postInstall = ''
    wrapProgram $out/bin/geteduroam-gui \
      --set-default PUREGOTK_LIB_FOLDER ${finalAttrs.passthru.libraryPath}/lib \
      ''${gappsWrapperArgs[@]}

    # copy notifcheck service
    mkdir -p $out/lib/systemd/system/
    cp -v systemd/user/geteduroam/* $out/lib/systemd/system/
    substituteInPlace $out/lib/systemd/system/geteduroam-notifs.service \
      --replace-fail \
        "ExecStart=/usr/bin/geteduroam-notifcheck" \
        "ExecStart=$out/bin/geteduroam-notifcheck"

    # copy icons and desktop entries
    cp -r cmd/geteduroam-gui/resources/share $out/
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dontWrapGApps = true;

  subPackages = [
    "cmd/geteduroam-gui"
    "cmd/geteduroam-notifcheck"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/geteduroam-gui";

  passthru = {
    libraryPath = symlinkJoin {
      name = "eduroam-gui-puregotk-lib";

      # based on https://github.com/jwijenbergh/puregotk/blob/bc1a52f44fd4c491947f7af85296c66173da17ba/internal/core/core.go#L41
      # cat "$(nix-build . -A geteduroam.goModules)"/*/*/puregotk/v4/*/*.go | grep -E 'SetSharedLibraries\(.*\)' -o | cut -d'"' -f4 | sort -u
      paths = [
        cairo
        gdk-pixbuf
        glib.out
        graphene
        gtk4
        libadwaita
        pango.out
      ];
    };
  };

  meta = {
    description = "GUI client to configure eduroam";
    homepage = "https://eduroam.app";
    changelog = "https://github.com/geteduroam/linux-app/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ pbsds ];
    platforms = lib.platforms.linux;
    mainProgram = "geteduroam-gui";
  };
})
