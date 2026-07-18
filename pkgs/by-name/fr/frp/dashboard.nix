{
  buildNpmPackage,
  frp,
}:
let
  builder =
    name:
    buildNpmPackage {
      inherit (frp) version src;
      pname = "${name}-dashboard";
      npmDepsHash = "sha256-XuqQPfywzK81anAD1pAl1TMQqb1+hH2QxLwuTn7zCPU=";

      preBuild = ''
        pushd ${name}
      '';

      installPhase = ''
        runHook preInstall
        cp -r dist $out
        runHook postInstall
      '';

      sourceRoot = "source/web";

      meta = frp.meta // {
        description = "Dashboard for frp";
      };
    };
in
{
  frpc = builder "frpc";
  frps = builder "frps";
}
