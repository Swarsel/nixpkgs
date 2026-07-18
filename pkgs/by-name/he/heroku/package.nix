{
  lib,
  stdenv,
  fetchzip,
  makeWrapper,
  nodejs,
  writeScript,
}:

stdenv.mkDerivation {
  pname = "heroku";
  version = "10.16.0";

  src = fetchzip {
    url = "https://cli-assets.heroku.com/versions/10.16.0/3f0b8a2/heroku-v10.16.0-3f0b8a2-linux-x64.tar.xz";
    hash = "sha256-WvabMaOvkaizRxA0d4Lk6pi693tpVd9VH7x77xuMzKU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/heroku $out/bin
    cp -pr * $out/share/heroku
    substituteInPlace $out/share/heroku/bin/run \
      --replace "/usr/bin/env node" "${nodejs}/bin/node"
    makeWrapper $out/share/heroku/bin/run $out/bin/heroku \
      --set HEROKU_DISABLE_AUTOUPDATE 1
  '';

  dontBuild = true;

  passthru.updateScript = writeScript "update-heroku" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -I nixpkgs=./. -i bash -p nix-prefetch curl jq common-updater-scripts
    resp="$(
        curl -L "https://cli-assets.heroku.com/versions/heroku-linux-x64-tar-xz.json" \
            | jq '[to_entries[] | { version: .key, url: .value } | select(.version|contains("-")|not)] | sort_by(.version|split(".")|map(tonumber)) | .[-1]'
    )"
    url="$(jq <<<"$resp" .url --raw-output)"
    version="$(jq <<<"$resp" .version --raw-output)"
    hash="$(nix-prefetch fetchzip --url "$(jq <<<"$resp" .url --raw-output)")"
    update-source-version heroku "$version" "$hash" "$url"
  '';

  meta = {
    description = "Everything you need to get started using Heroku";
    homepage = "https://devcenter.heroku.com/articles/heroku-cli";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aflatter
      mirdhyn
    ];

    platforms = with lib.platforms; unix;
    mainProgram = "heroku";
  };
}
