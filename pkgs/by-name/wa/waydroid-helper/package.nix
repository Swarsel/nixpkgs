{
  lib,
  fetchFromGitHub,
  android-tools,
  appstream,
  bash,
  bindfs,
  cmake,
  dbus,
  desktop-file-utils,
  e2fsprogs,
  fakeroot,
  fetchpatch,
  glib,
  gobject-introspection,
  libadwaita,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  systemd,
  unzip,
  vte-gtk4,
  wrapGAppsHook4,
}:

let
  version = "0.2.9";

  src = fetchFromGitHub {
    owner = "ayasa520";
    repo = "waydroid-helper";
    tag = "v${version}";
    hash = "sha256-6mVb4GPD2NCsvyaqQAOFox0rNIlyOttiaZKbHBS40Rg=";
  };
in
python3Packages.buildPythonApplication {
  inherit version src;
  pname = "waydroid-helper";

  patches = [
    # remove for next release
    (fetchpatch {
      hash = "sha256-z0PWBZTox3RpPCm8/fGYEukU0v41U7/TFcYE0Ec5Zeg=";
      name = "USE_UMOUNT_NOT_FUSERMOUNT";
      url = "https://github.com/waydroid-helper/waydroid-helper/commit/eb8ccf7a276f95b31972edbd063245704b2b5b2e.patch";
    })
  ];

  postPatch = ''
    substituteInPlace dbus/meson.build \
      --replace-fail "dbus_policy_dir," "'$out/share/dbus-1/system.d'," \
      --replace-fail "dbus_service_dir," "'$out/share/dbus-1/system-services',"
    substituteInPlace systemd/meson.build \
      --replace-fail ": systemd_system_unit_dir" ": '$out/lib/systemd/system'" \
      --replace-fail ": systemd_user_unit_dir" ": '$out/lib/systemd/user'"
    substituteInPlace systemd/{system/waydroid-mount,user/waydroid-monitor}.service \
      --replace-fail "/usr/bin/waydroid-helper" "$out/bin/waydroid-helper"
  ''
  # com.jaoushingan.WaydroidHelper.desktop: component-name-missing, description-first-para-too-short
  # url-homepage-missing, desktop-app-launchable-omitted, content-rating-missing, developer-info-missing
  + ''
    sed -i '/test(/{N;/Validate appstream file/!b;:a;N;/)/!ba;d}' data/meson.build
  '';

  strictDeps = true;

  nativeBuildInputs = [
    appstream
    cmake
    desktop-file-utils
    glib
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    bash
    dbus
    libadwaita
    libxml2
    systemd
    vte-gtk4
  ];

  dependencies = with python3Packages; [
    aiofiles
    dbus-python
    httpx
    pygobject3
    pyyaml
    pywayland
  ];

  dontUseCmakeConfigure = true;
  dontWrapGApps = true;

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
    "--prefix PATH : ${
      lib.makeBinPath [
        android-tools
        bindfs
        e2fsprogs
        fakeroot
        unzip
      ]
    }"
  ];

  postInstallCheck = ''
    mesonCheckPhase
  '';

  pyproject = false; # uses meson
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "User-friendly way to configure Waydroid and install extensions, including Magisk and ARM translation";
    homepage = "https://github.com/ayasa520/waydroid-helper";
    changelog = "https://github.com/ayasa520/waydroid-helper/releases/tag/${src.tag}";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "waydroid-helper";
  };
}
