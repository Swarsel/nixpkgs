{
  lib,
  stdenv,
  fetchurl,
  binaryName,
  branch,
  brotli,
  desktopName,
  equicord,
  makeWrapper,
  meta,
  moonlight,
  openasar,
  pname,
  python3,
  runCommand,
  self,
  source,
  vencord,
  writeScript,
  writeShellScript,
  commandLineArgs ? "",
  withEquicord ? false,
  withMoonlight ? false,
  withOpenASAR ? false,
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

  configDirName = lib.replaceStrings [ " " ] [ "" ] (lib.toLower binaryName);

  fixDistroSymlinks = writeScript "discord-fix-distro-symlinks.py" ''
    #!${python3.interpreter}
    import pathlib
    import sys
    import tarfile

    with tarfile.open(sys.argv[1]) as tar:
        for member in tar:
            if not member.issym():
                continue
            parts = pathlib.PurePosixPath(member.name).parts[1:]
            if not parts:
                continue
            path = pathlib.Path(sys.argv[2], *parts)
            path.unlink(missing_ok=True)
            path.symlink_to(member.linkname)
  '';

  stageModules = writeShellScript "discord-stage-modules" ''
    store_modules="$1"
    modules_dir="$HOME/Library/Application Support/${configDirName}/${version}/modules"
    mkdir -p "$modules_dir"
    for m in ${lib.concatStringsSep " " (lib.attrNames moduleSrcs)}; do
      ln -sfn "$store_modules/$m" "$modules_dir/$m"
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
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [
    brotli
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications

    extractDistro() {
      local src="$1"
      local dest="$2"
      local tarball
      tarball=$(mktemp)
      brotli -d < "$src" > "$tarball"
      tar xf "$tarball" --strip-components=1 -C "$dest"

      # Discord's distro tarballs store symlinks with mode 000, which makes
      # them unreadable on Darwin. Recreate them with normal permissions.
      ${fixDistroSymlinks} "$tarball" "$dest"
      rm "$tarball"
    }

    extractDistro "$src" "$out/Applications"

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: src: ''
        mkdir -p "$out/Applications/${desktopName}.app/Contents/Resources/modules/${name}"
        extractDistro ${src} "$out/Applications/${desktopName}.app/Contents/Resources/modules/${name}"
      '') moduleSrcs
    )}

    # wrap executable to $out/bin
    mkdir -p $out/bin
    makeWrapper "$out/Applications/${desktopName}.app/Contents/MacOS/${binaryName}" "$out/bin/${binaryName}" \
      --run ${lib.getExe disableBreakingUpdates} \
      --run "${stageModules} \"$out/Applications/${desktopName}.app/Contents/Resources/modules\"" \
      --add-flags ${lib.escapeShellArg commandLineArgs}

    runHook postInstall
  '';

  postInstall =
    lib.strings.optionalString withOpenASAR ''
      cp -f ${openasar} "$out/Applications/${desktopName}.app/Contents/Resources/app.asar"
    ''
    + lib.strings.optionalString withVencord ''
      mv "$out/Applications/${desktopName}.app/Contents/Resources/app.asar" "$out/Applications/${desktopName}.app/Contents/Resources/_app.asar"
      mkdir "$out/Applications/${desktopName}.app/Contents/Resources/app.asar"
      echo '{"name":"discord","main":"index.js"}' > "$out/Applications/${desktopName}.app/Contents/Resources/app.asar/package.json"
      echo 'require("${vencord}/patcher.js")' > "$out/Applications/${desktopName}.app/Contents/Resources/app.asar/index.js"
    ''
    + lib.strings.optionalString withEquicord ''
      mv "$out/Applications/${desktopName}.app/Contents/Resources/app.asar" "$out/Applications/${desktopName}.app/Contents/Resources/_app.asar"
      mkdir "$out/Applications/${desktopName}.app/Contents/Resources/app.asar"
      echo '{"name":"discord","main":"index.js"}' > "$out/Applications/${desktopName}.app/Contents/Resources/app.asar/package.json"
      echo 'require("${equicord}/desktop/patcher.js")' > "$out/Applications/${desktopName}.app/Contents/Resources/app.asar/index.js"
    ''
    + lib.strings.optionalString withMoonlight ''
      mv "$out/Applications/${desktopName}.app/Contents/Resources/app.asar" "$out/Applications/${desktopName}.app/Contents/Resources/_app.asar"
      mkdir "$out/Applications/${desktopName}.app/Contents/Resources/app.asar"
      echo '{"name":"discord","main":"injector.js","private": true}' > "$out/Applications/${desktopName}.app/Contents/Resources/app.asar/package.json"
      echo 'require("${moonlight}/injector.js").inject(require("path").join(__dirname, "../_app.asar"));' > "$out/Applications/${desktopName}.app/Contents/Resources/app.asar/injector.js"
    '';

  dontStrip = true;
  dontUnpack = true;
  sourceRoot = ".";

  passthru = {
    # make it possible to run disableBreakingUpdates standalone
    inherit disableBreakingUpdates;
    inherit source;

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
}
