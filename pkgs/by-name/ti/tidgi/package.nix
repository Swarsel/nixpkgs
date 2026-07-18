{
  lib,
  stdenv,
  fetchurl,
  ast-grep,
  common-updater-scripts,
  jq,
  unzip,
  writeShellScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tidgi";
  version = "0.12.4";

  src =
    {
      aarch64-darwin = fetchurl {
        hash = "sha256-bSJFM67+KVECUqjwu1HYipn+zOps1ahNzM721yZL52c=";
        url = "https://github.com/tiddly-gittly/TidGi-Desktop/releases/download/v${finalAttrs.version}/TidGi-darwin-arm64-${finalAttrs.version}.zip";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -r *.app "$out/Applications"

    runHook postInstall
  '';

  dontBuild = true;
  sourceRoot = ".";

  passthru.updateScript = writeShellScript "update-tidgi" ''
    version=$(nix eval --raw --file . tidgi.version)
    latestVersion=$(curl ''${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} --fail --silent https://api.github.com/repos/tiddly-gittly/TidGi-Desktop/releases/latest | ${lib.getExe jq} --raw-output .tag_name | sed 's/^v//')
    if [[ "$latestVersion" == "$version" ]]; then
      exit 0
    fi
    ${lib.getExe ast-grep} scan --inline-rules "
    id: update-version
    language: nix
    rule:
      kind: binding
      regex: '^\s*version\s*='
    fix: 'version = \"$latestVersion\";'
    " --update-all $(env EDITOR=echo nix edit --file . tidgi)
    systems=$(nix eval --json -f . tidgi.meta.platforms | ${lib.getExe jq} --raw-output '.[]')
    for system in $systems; do
      hash=$(nix hash convert --to sri --hash-algo sha256 $(nix-prefetch-url $(nix eval --raw --file . tidgi.src.url --system "$system")))
      ${lib.getExe' common-updater-scripts "update-source-version"} tidgi $latestVersion $hash --system=$system --ignore-same-version --ignore-same-hash
    done
  '';

  meta = {
    description = "Customizable personal knowledge-base and blogging platform with git as backup manager";
    homepage = "https://github.com/tiddly-gittly/TidGi-Desktop";
    changelog = "https://github.com/tiddly-gittly/TidGi-Desktop/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ klchen0112 ];

    platforms = [
      "aarch64-darwin"
    ];
  };
})
