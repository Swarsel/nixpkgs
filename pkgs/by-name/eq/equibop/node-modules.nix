# fixed output derrivation adapted from
# https://github.com/NixOS/nixpkgs/blob/28c3f83a9a77e3ada57afb71cc4052d2c435597a/pkgs/by-name/op/opencode/package.nix#L59-L122
{
  lib,
  bun,
  equibop,
  stdenvNoCC,
  writableTmpDirAsHomeHook,
}:
stdenvNoCC.mkDerivation {
  inherit (equibop) version src;
  pname = equibop.pname + "-modules";

  nativeBuildInputs = [
    bun
    writableTmpDirAsHomeHook
  ];

  buildPhase = ''
    runHook preBuild

    export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

    bun install \
        --filter=equibop \
        --force \
        --frozen-lockfile \
        --ignore-scripts \
        --linker=hoisted \
        --no-progress

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -R ./node_modules $out

    runHook postInstall
  '';

  dontConfigure = true;
  dontFixup = true;

  impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
    "GIT_PROXY_COMMAND"
    "SOCKS_SERVER"
  ];

  outputHash =
    {
      aarch64-linux = "sha256-Zrk0aTHw7nrN6lKFa/ap7Hz1OJwnY4jtCLw2KWWqyJQ=";
      x86_64-linux = "sha256-dLATw5Mb9grQnI/JTdlRdNP2JETELeqY8aXqb5dCXOA=";
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system ${stdenvNoCC.hostPlatform.system}");

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
}
