{ buildNpmPackage }:

{
  meta,
  src,
  version,
}:

buildNpmPackage {
  inherit version src;
  pname = "coolercontrol-ui";
  npmDepsHash = "sha256-zolbx5ROiFzNhPGcOnJjEiY3W2IXI24wLKPj3wRSLXU=";

  postBuild = ''
    cp -r dist $out
  '';

  dontInstall = true;
  npmDepsFetcherVersion = 2;
  sourceRoot = "${src.name}/coolercontrol-ui";

  meta = meta // {
    description = "${meta.description} (UI data)";
  };
}
