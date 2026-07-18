{
  makeWrapper,
  plugins,
  puredata,
  symlinkJoin,
}:

let
  puredataFlags = map (x: "-path ${x}/") plugins;
in
symlinkJoin {
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/pd \
      --add-flags "${toString puredataFlags}"
  '';

  name = "puredata-with-plugins-${puredata.version}";
  paths = [ puredata ] ++ plugins;
}
