{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  buildFHSEnv,
  dotnetCorePackages,
  # webkitgtk_4_0,
  e2fsprogs,
  file,
  glib-networking,
  glibc,
  gsettings-desktop-schemas,
  gtk3,
  libappindicator,
  libgit2,
  libnotify,
  openjdk,
  openssl,
  patchelf,
  wrapGAppsHook3,
  writeShellScript,
  xdelta,
}:
let
  am2r-run = buildFHSEnv {
    multiArch = true;

    multiPkgs =
      pkgs: with pkgs; [
        (lib.getLib stdenv.cc.cc)
        libx11
        libxext
        libxrandr
        libxxf86vm
        curl
        libGLU
        libglvnd
        openal
        zlib
      ];

    name = "am2r-run";

    runScript = writeShellScript "am2r-run" ''
      exec -- "$1" "$@"
    '';
  };
in
buildDotnetModule {
  pname = "am2rlauncher";
  version = "2.3.0-unstable-2023-11-08";

  src = fetchFromGitHub {
    owner = "AM2R-Community-Developers";
    repo = "AM2RLauncher";
    rev = "5d8b7d9b3de68e6215c10b9fd223b7f1d5e40dea";
    hash = "sha256-/nHqo8jh3sOUngbpqdfiQjUWO/8Uzpc5jtW7Ep4q6Wg=";
  };

  patches = [
    ./am2r-run-binary.patch
    ./dotnet-8-upgrade.patch
  ];

  nativeBuildInputs = [ wrapGAppsHook3 ];

  buildInputs = [
    gtk3
    gsettings-desktop-schemas
    glib-networking
  ];

  postFixup = ''
    mkdir -p $out/share/icons
    install -Dm644 $src/AM2RLauncher/distribution/linux/AM2RLauncher.png $out/share/icons/AM2RLauncher.png
    install -Dm644 $src/AM2RLauncher/distribution/linux/AM2RLauncher.desktop $out/share/applications/AM2RLauncher.desktop

    # renames binary for desktop file
    mv $out/bin/AM2RLauncher.Gtk $out/bin/AM2RLauncher
  '';

  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  dotnetFlags = [
    ''-p:DefineConstants="NOAPPIMAGE;NOAUTOUPDATE;PATCHOPENSSL"''
  ];

  executables = "AM2RLauncher.Gtk";

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.escapeShellArg (
      lib.makeBinPath [
        am2r-run
        xdelta
        file
        openjdk
        patchelf
      ]
    ))
  ];

  nugetDeps = ./deps.json;
  projectFile = "AM2RLauncher/AM2RLauncher.Gtk/AM2RLauncher.Gtk.csproj";

  runtimeDeps = [
    glibc
    gtk3
    libappindicator
    # webkitgtk_4_0
    e2fsprogs
    libnotify
    libgit2
    openssl
  ];

  meta = {
    description = "Front-end for dealing with AM2R updates and mods";

    longDescription = ''
      A front-end application that simplifies installing the latest
      AM2R-Community-Updates, creating APKs for Android use, as well as Mods for
      AM2R.
    '';

    homepage = "https://github.com/AM2R-Community-Developers/AM2RLauncher";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nsnelson ];
    platforms = lib.platforms.linux;
    mainProgram = "AM2RLauncher";
    # webkitgtk_4_0 was removed
    broken = true;
  };
}
