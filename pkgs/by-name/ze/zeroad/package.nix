{
  buildEnv,
  makeWrapper,
  zeroad-data,
  zeroad-unwrapped,
}:

assert zeroad-unwrapped.version == zeroad-data.version;

buildEnv {
  inherit (zeroad-unwrapped) version;
  pname = "zeroad";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    for i in $out/bin/*; do
      wrapProgram "$i" \
        --set ZEROAD_ROOTDIR "$out/share/0ad"
    done
  '';

  paths = [
    zeroad-unwrapped
    zeroad-data
  ];

  pathsToLink = [
    "/"
    "/bin"
  ];

  meta = zeroad-unwrapped.meta // {
    hydraPlatforms = [ ];
  };
}
