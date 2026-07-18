{
  buildEnv,
  makeWrapper,
  snis-assets,
  snis-unwrapped,
}:
buildEnv {
  inherit (snis-unwrapped) version;
  pname = "snis";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    for i in $out/bin/*; do
      wrapProgram "$i" \
        --set SNIS_ASSET_DIR "$out/share/snis"
    done
  '';

  # Basic assets are also distributed in the main repo
  ignoreCollisions = true;

  paths = [
    snis-unwrapped
    snis-assets
  ];

  pathsToLink = [
    "/"
    "/bin"
  ];

  meta = snis-unwrapped.meta // {
    hydraPlatforms = [ ];
  };
}
