/*
  The reusable code, and package attributes, between OpenRA engine packages (engine.nix)
   and out-of-tree mod packages (mod.nix).
*/
{
  lib,
  SDL2,
  curl,
  dos2unix,
  freetype,
  libGL,
  lua,
  makeSetupHook,
  makeWrapper,
  mono,
  openal,
  pkg-config,
  python3,
  unzip,
  # It is not necessary to run the game, but it is nicer to be given an error dialog in the case of failure,
  # rather than having to look to the logs why it is not starting.
  zenity,
}:

let
  inherit (lib)
    licenses
    maintainers
    makeBinPath
    makeLibraryPath
    optional
    platforms
    ;

  path = makeBinPath (
    [
      mono
      python3
    ]
    ++ optional (zenity != null) zenity
  );
  rpath = makeLibraryPath [
    lua
    freetype
    openal
    SDL2
  ];
  mkdirp = makeSetupHook {
    name = "openra-mkdirp-hook";
    meta.license = lib.licenses.mit;
  } ./mkdirp.sh;

in
{
  packageAttrs = {
    # TODO: Test if this is correct.
    nativeBuildInputs = [
      curl
      unzip
      dos2unix
      pkg-config
      makeWrapper
      mkdirp
      mono
      python3
    ];

    buildInputs = [ libGL ];
    makeFlags = [ "prefix=$(out)" ];
    doCheck = true;
    dontStrip = true;

    meta = {
      license = licenses.gpl3;

      maintainers = with maintainers; [
        fusion809
        msteen
      ];

      platforms = platforms.linux;
    };
  };

  patchEngine = dir: version: ''
    sed -i \
      -e 's/^VERSION.*/VERSION = ${version}/g' \
      -e '/fetch-geoip-db/d' \
      -e '/GeoLite2-Country.mmdb.gz/d' \
      ${dir}/Makefile

    sed -i 's|locations=.*|locations=${lua}/lib|' ${dir}/thirdparty/configure-native-deps.sh
  '';

  wrapLaunchGame = openraSuffix: binaryName: ''
    # Setting TERM=xterm fixes an issue with terminfo in mono: System.Exception: Magic number is wrong: 542
    # https://github.com/mono/mono/issues/6752#issuecomment-365212655
    wrapProgram $out/lib/openra${openraSuffix}/launch-game.sh \
      --prefix PATH : "${path}" \
      --prefix LD_LIBRARY_PATH : "${rpath}" \
      --set TERM xterm

    makeWrapper $out/lib/openra${openraSuffix}/launch-game.sh $(mkdirp $out/bin)/${binaryName} \
      --chdir "$out/lib/openra${openraSuffix}"
  '';
}
