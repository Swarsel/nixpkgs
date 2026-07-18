{
  stdenv,
  imagemagick,
  symlinkJoin,
  torcs-without-data,
}:
let
  # This package is split into two parts because the complete package includes
  # the game data, which takes up a lot of space and is not worth serving from
  # the official cache. The compiled program gets built by Hydra and cached,
  # while the game data does not and gets handled locally instead.
  torcs-data = stdenv.mkDerivation (finalAttrs: {
    inherit (torcs-without-data)
      version
      src
      buildInputs
      ;

    pname = "torcs-data";

    postInstall = ''
      mkdir -p $out/share/icons/hicolor/64x64/apps
      ${imagemagick}/bin/magick Ticon.png -resize 64x64 $out/share/icons/hicolor/64x64/apps/torcs.png

      substituteInPlace torcs.desktop \
        --replace-fail "Icon=torcs.png" "Icon=torcs"
      install -D -m644 torcs.desktop $out/share/applications/torcs.desktop
    '';

    dontBuild = true;
    installTargets = "export datainstall";
    meta.hydraPlatforms = [ ];
  });
in
symlinkJoin {
  inherit (torcs-without-data)
    version
    ;

  pname = "torcs";

  postBuild = ''
    cp --remove-destination $(realpath $out/bin/torcs) $out/bin/torcs
    substituteInPlace $out/bin/torcs \
      --replace-fail "${torcs-without-data}" "$out"
  '';

  paths = [
    torcs-without-data
    torcs-data
  ];

  meta = torcs-without-data.meta // {
    description = "Car racing game";
    hydraPlatforms = [ ];
  };
}
