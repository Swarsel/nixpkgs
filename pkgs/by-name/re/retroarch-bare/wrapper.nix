{
  lib,
  libretro,
  makeBinaryWrapper,
  retroarch-bare,
  symlinkJoin,
  writeText,
  cores ? [ ],
  settings ? { },
}:

let
  settingsPath = writeText "declarative-retroarch.cfg" (
    lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: "${n} = \"${v}\"") settings)
  );

  # All cores should be located in the same path after symlinkJoin,
  # but let's be safe here
  coresPath = lib.lists.unique (map (c: c.libretroCore) cores);
  wrapperArgs = lib.strings.escapeShellArgs (
    (lib.lists.flatten (
      map (p: [
        "--add-flags"
        "-L ${placeholder "out" + p}"
      ]) coresPath
    ))
    ++ [
      "--add-flags"
      "--appendconfig=${settingsPath}"
    ]
  );
in
symlinkJoin {
  pname = "retroarch-with-cores";
  version = lib.getVersion retroarch-bare;
  nativeBuildInputs = [ makeBinaryWrapper ];

  postBuild = ''
    # remove core specific binaries
    find $out/bin -name 'retroarch-*' -type l -delete

    # wrap binary to load cores from the proper location(s)
    wrapProgram $out/bin/retroarch ${wrapperArgs}
  '';

  paths = [ retroarch-bare ] ++ cores;

  passthru = {
    inherit cores;
    unwrapped = retroarch-bare;
    withCores = coreFun: retroarch-bare.wrapper { cores = (coreFun libretro); };
  };

  meta = {
    inherit (retroarch-bare.meta)
      changelog
      description
      homepage
      license
      mainProgram
      maintainers
      teams
      platforms
      ;

    longDescription = ''
      RetroArch is the reference frontend for the libretro API.
    ''
    + lib.optionalString (cores != [ ]) ''
      The following cores are included: ${lib.concatStringsSep ", " (map (c: c.core) cores)}.
    '';
  };
}
