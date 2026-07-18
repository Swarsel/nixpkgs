{
  lib,
  stdenv,
  fetchurl,
  addDriverRunpath,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  autoPatchelfHook,
  binaryName,
  branch,
  brotli,
  cairo,
  cups,
  dbus,
  desktopName,
  equicord,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libappindicator-gtk3,
  libcxx,
  libdbusmenu,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libpulseaudio,
  libunity,
  libuuid,
  libva,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  makeDesktopItem,
  makeShellWrapper,
  meta,
  moonlight,
  nspr,
  nss,
  openasar,
  pango,
  pipewire,
  pname,
  python3,
  runCommand,
  self,
  source,
  speechd-minimal,
  systemdLibs,
  vencord,
  wayland,
  wrapGAppsHook3,
  writeShellScript,
  commandLineArgs ? "",
  # Disabling this would normally break Discord.
  # The intended use-case for this is when SKIP_HOST_UPDATE is enabled via other means,
  # for example if a settings.json is linked declaratively (e.g., with home-manager).
  disableUpdates ? true,
  enableAutoscroll ? false,
  withEquicord ? false,
  withMoonlight ? false,
  withOpenASAR ? false,
  withTTS ? true,
  withVencord ? false,
}:

let
  discordMods = [
    withVencord
    withEquicord
    withMoonlight
  ];
  enabledDiscordModsCount = builtins.length (lib.filter (x: x) discordMods);

  inherit (source) version;

  src = fetchurl { inherit (source.distro) url hash; };

  moduleSrcs = lib.mapAttrs (_: mod: fetchurl { inherit (mod) url hash; }) source.modules;

  moduleVersions = lib.mapAttrs (_: mod: mod.version) source.modules;

  libPath = lib.makeLibraryPath (
    [
      libcxx
      systemdLibs
      libpulseaudio
      libdrm
      libgbm
      stdenv.cc.cc
      alsa-lib
      atk
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libglvnd
      libnotify
      libx11
      libxcomposite
      libunity
      libuuid
      libva
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxtst
      nspr
      # nss is intentionally NOT in libPath: it would leak via LD_LIBRARY_PATH
      # to xdg-open and break Firefox children when versions diverge (#514859,
      # PR #186603)
      libxcb
      libxkbcommon
      pango
      pipewire
      libxscrnsaver
      libappindicator-gtk3
      libdbusmenu
      wayland
    ]
    ++ lib.optionals withTTS [ speechd-minimal ]
  );

  # Symlink native modules from the nix store into the user config dir
  # where Discord's JS moduleUpdater expects them.
  stageModules = writeShellScript "discord-stage-modules" ''
    store_modules="$1"
    modules_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/${lib.toLower binaryName}/${version}/modules"
    rm -rf "$modules_dir"
    mkdir -p "$modules_dir"
    for m in ${lib.concatStringsSep " " (lib.attrNames moduleSrcs)}; do
      ln -sn "$store_modules/$m" "$modules_dir/$m"
    done
    echo '${builtins.toJSON (lib.mapAttrs (_: mod: { installedVersion = mod; }) moduleVersions)}' \
      > "$modules_dir/installed.json"
  '';

  disableBreakingUpdates =
    runCommand "disable-breaking-updates.py"
      {
        configDirName = lib.toLower binaryName;
        pythonInterpreter = "${python3.interpreter}";
        skipModuleUpdate = lib.boolToString withOpenASAR;
        meta.mainProgram = "disable-breaking-updates.py";
      }
      ''
        mkdir -p $out/bin
        cp ${./disable-breaking-updates.py} $out/bin/disable-breaking-updates.py
        substituteAllInPlace $out/bin/disable-breaking-updates.py
        chmod +x $out/bin/disable-breaking-updates.py
      '';
in
assert lib.assertMsg (
  enabledDiscordModsCount <= 1
) "discord: Only one of Vencord, Equicord or Moonlight can be enabled at the same time";
stdenv.mkDerivation (finalAttrs: {
  inherit
    pname
    version
    src
    meta
    ;

  inherit libPath stageModules;
  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    cups
    libdrm
    libuuid
    libxdamage
    libx11
    libxscrnsaver
    libxtst
    libxcb
    libxshmfence
    wrapGAppsHook3
    makeShellWrapper
    brotli
  ];

  buildInputs = [
    alsa-lib
    libgbm
    nspr
    nss
    # The distro layout ships prebuilt `.node` modules:
    # discord_dispatch is linked against openssl 1.1, discord_voice against libpulseaudio.
    # Ignore the missing dependency on insecure openssl_1_1: discord_dispatch is
    # effectively unused in practice.
    libpulseaudio
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,opt/${binaryName},share/icons/hicolor/256x256/apps}

    # The host distro is a brotli-compressed tar with all files under a `files/`
    # prefix (the channel binary, libffmpeg.so, resources/, etc). Module distros
    # follow the same format with module contents under `files/`
    brotli -d < $src | tar xf - --strip-components=1 -C $out/opt/${binaryName}
    chmod +x $out/opt/${binaryName}/${binaryName}

    # The module directory layout must match what Discord's node runtime
    # expects: modules/<name>/ (the moduleUpdater extracts zips into
    # path.join(moduleInstallPath, moduleName) see processUnzipQueue)
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: src: ''
        mkdir -p $out/opt/${binaryName}/modules/${name}
        brotli -d < ${src} | tar xf - --strip-components=1 -C $out/opt/${binaryName}/modules/${name}
      '') moduleSrcs
    )}

    wrapProgramShell $out/opt/${binaryName}/${binaryName} \
        "''${gappsWrapperArgs[@]}" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
        ${lib.strings.optionalString withTTS ''
          --run 'if [[ "''${NIXOS_SPEECH:-default}" != "False" ]]; then NIXOS_SPEECH=True; else unset NIXOS_SPEECH; fi' \
          --add-flags "\''${NIXOS_SPEECH:+--enable-speech-dispatcher}" \
        ''} \
        ${lib.strings.optionalString enableAutoscroll "--add-flags \"--enable-blink-features=MiddleClickAutoscroll\""} \
        --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}/" \
        --prefix LD_LIBRARY_PATH : ${finalAttrs.libPath}:$out/opt/${binaryName}:${addDriverRunpath.driverLink}/lib \
        --suffix VK_ADD_DRIVER_FILES : "${addDriverRunpath.driverLink}/share/vulkan/icd.d" \
        ${lib.strings.optionalString disableUpdates "--run ${lib.getExe disableBreakingUpdates}"} \
        --run "${finalAttrs.stageModules} $out/opt/${binaryName}/modules" \
        --add-flags ${lib.escapeShellArg commandLineArgs}

    ln -s $out/opt/${binaryName}/${binaryName} $out/bin/
    # Without || true the install would fail on case-insensitive filesystems
    ln -s $out/opt/${binaryName}/${binaryName} $out/bin/${lib.strings.toLower binaryName} || true

    ln -s $out/opt/${binaryName}/discord.png $out/share/icons/hicolor/256x256/apps/${pname}.png

    ln -s "$desktopItem/share/applications" $out/share/

    runHook postInstall
  '';

  postInstall =
    lib.strings.optionalString withOpenASAR ''
      cp -f ${openasar} $out/opt/${binaryName}/resources/app.asar
    ''
    + lib.strings.optionalString withVencord ''
      mv $out/opt/${binaryName}/resources/app.asar $out/opt/${binaryName}/resources/_app.asar
      mkdir $out/opt/${binaryName}/resources/app.asar
      echo '{"name":"discord","main":"index.js"}' > $out/opt/${binaryName}/resources/app.asar/package.json
      echo 'require("${vencord}/patcher.js")' > $out/opt/${binaryName}/resources/app.asar/index.js
    ''
    + lib.strings.optionalString withEquicord ''
      mv $out/opt/${binaryName}/resources/app.asar $out/opt/${binaryName}/resources/_app.asar
      mkdir $out/opt/${binaryName}/resources/app.asar
      echo '{"name":"discord","main":"index.js"}' > $out/opt/${binaryName}/resources/app.asar/package.json
      echo 'require("${equicord}/desktop/patcher.js")' > $out/opt/${binaryName}/resources/app.asar/index.js
    ''
    + lib.strings.optionalString withMoonlight ''
      mv $out/opt/${binaryName}/resources/app.asar $out/opt/${binaryName}/resources/_app.asar
      mkdir $out/opt/${binaryName}/resources/app
      echo '{"name":"discord","main":"injector.js","private": true}' > $out/opt/${binaryName}/resources/app/package.json
      echo 'require("${moonlight}/injector.js").inject(require("path").join(__dirname, "../_app.asar"));' > $out/opt/${binaryName}/resources/app/injector.js
    '';

  autoPatchelfIgnoreMissingDeps = [
    "libssl.so.1.1"
    "libcrypto.so.1.1"
  ];

  desktopItem = makeDesktopItem {
    inherit desktopName;

    categories = [
      "Network"
      "InstantMessaging"
    ];

    exec = binaryName;
    genericName = meta.description;
    icon = pname;
    mimeTypes = [ "x-scheme-handler/discord" ];
    name = pname;
    startupWMClass = "discord";
  };

  dontUnpack = true;
  dontWrapGApps = true;

  passthru = {
    # make it possible to run disableBreakingUpdates standalone
    inherit disableBreakingUpdates;
    # Exposed so reviewers can inspect which distro modules are pinned
    inherit source moduleVersions;

    tests = {
      withEquicord = self.override {
        withEquicord = true;
      };

      withMoonlight = self.override {
        withMoonlight = true;
      };

      withOpenASAR = self.override {
        withOpenASAR = true;
      };

      withVencord = self.override {
        withVencord = true;
      };
    };

    updateScript = ./update.py;
  };
})
