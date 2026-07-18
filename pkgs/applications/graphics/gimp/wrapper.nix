{
  lib,
  gimpPlugins,
  gnome-themes-extra,
  makeWrapper,
  symlinkJoin,
  plugins ? null,
}:

let
  inherit (gimpPlugins) gimp;
  allPlugins = lib.filter (pkg: lib.isDerivation pkg && !pkg.meta.broken or false) (
    lib.attrValues gimpPlugins
  );
  selectedPlugins = lib.filter (pkg: pkg != gimp) (if plugins == null then allPlugins else plugins);
  extraArgs =
    map (x: x.wrapArgs or "") selectedPlugins
    ++ lib.optionals (gimp.apiVersion == "2.0") [
      ''--prefix GTK_PATH : "${gnome-themes-extra}/lib/gtk-2.0"''
    ];
  majorVersion = lib.versions.major gimp.version;

in
symlinkJoin {
  inherit (gimp) version;
  pname = "gimp-with-plugins";

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    for each in gimp-${gimp.appVersion} gimp-console-${gimp.appVersion}; do
      wrapProgram $out/bin/$each \
        --set GIMP${majorVersion}_PLUGINDIR "$out/${gimp.targetLibDir}" \
        --set GIMP${majorVersion}_DATADIR "$out/${gimp.targetDataDir}" \
        ${toString extraArgs}
    done
    set +x
    for each in gimp gimp-console; do
      ln -sf "$each-${gimp.appVersion}" $out/bin/$each
    done

    ln -s ${gimp.man} $man
  '';

  paths = [ gimp ] ++ selectedPlugins;

  meta = gimp.meta // {
    description = "${gimp.meta.description} with plugins";

    longDescription = ''
      Plugins:

      ${lib.concatMapStringsSep "\n" (p: "- ${p.pname}") selectedPlugins}
    '';
  };
}
