{
  deadbeef,
  makeWrapper,
  symlinkJoin,
  plugins ? [ ],
}:

symlinkJoin {
  inherit (deadbeef) version;
  pname = "deadbeef-with-plugins";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/deadbeef \
      --set DEADBEEF_PLUGIN_DIR "$out/lib/deadbeef"
  '';

  paths = [ deadbeef ] ++ plugins;
}
