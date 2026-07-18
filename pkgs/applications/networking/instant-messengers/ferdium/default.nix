{
  lib,
  stdenv,
  fetchurl,
  common-updater-scripts,
  jq,
  libxshmfence,
  mkFranzDerivation,
  nix,
  nix-update,
  writeShellScript,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "ferdium: arch ${system} not supported";

  arch =
    {
      aarch64-linux = "arm64";
      x86_64-linux = "amd64";
    }
    .${system} or throwSystem;

  hash =
    {
      aarch64-linux = "sha256-CYHoTw6JUyU63iTd9tAbfWVnb48WcZgGtjthqnlAD8I=";
      x86_64-linux = "sha256-ODQKFjBa2riJY26aPaAfLzuCyLYkB5oYSxIE28nMmwY=";
    }
    .${system} or throwSystem;
in
mkFranzDerivation rec {
  pname = "ferdium";
  version = "7.1.2";

  src = fetchurl {
    inherit hash;
    url = "https://github.com/ferdium/ferdium-app/releases/download/v${version}/Ferdium-linux-${version}-${arch}.deb";
  };

  extraBuildInputs = [ libxshmfence ];
  name = "Ferdium";

  passthru.updateScript = writeShellScript "update-ferdium" ''
    ${lib.getExe nix-update} ferdium --no-src --override-filename pkgs/applications/networking/instant-messengers/ferdium/default.nix
    latestVersion=$(nix eval --raw --file . ferdium.version)
    if [[ "$latestVersion" == "$UPDATE_NIX_OLD_VERSION" ]]; then
      exit 0
    fi
    for system in x86_64-linux aarch64-linux; do
      hash=$(${lib.getExe nix} store prefetch-file --json \
        "$(nix eval --raw --file . ferdium.src.url --argstr system "$system")" \
        | ${lib.getExe jq} --raw-output .hash)
      ${lib.getExe' common-updater-scripts "update-source-version"} \
        ferdium "$latestVersion" "$hash" --system="$system" \
        --ignore-same-version --ignore-same-hash
    done
  '';

  meta = {
    description = "All your services in one place built by the community";
    homepage = "https://ferdium.org/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ magnouvean ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    hydraPlatforms = [ ];
  };
}
