{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  nixosTests,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "uptime-kuma";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "louislam";
    repo = "uptime-kuma";
    tag = finalAttrs.version;
    hash = "sha256-iqkf9/UAQOnSA+nncK/fmjbqZpIQeUmigI/78m5qKrM=";
  };

  patches = [
    # Fixes the permissions of the database being not set correctly
    # See https://github.com/louislam/uptime-kuma/pull/2119
    ./fix-database-permissions.patch
  ];

  npmDepsHash = "sha256-chvykBfnARLto+Il9gumm6UTRSTPPBjg5pj4yGFiOcg=";

  postInstall = ''
    cp -r dist $out/lib/node_modules/uptime-kuma/

    # remove references to nodejs source
    rm -r $out/lib/node_modules/uptime-kuma/node_modules/@louislam/sqlite3/build-tmp-napi-v*
  '';

  postFixup = ''
    makeWrapper ${nodejs}/bin/node $out/bin/uptime-kuma-server \
      --add-flags $out/lib/node_modules/uptime-kuma/server/server.js \
      --chdir $out/lib/node_modules/uptime-kuma
  '';

  passthru.tests.uptime-kuma = nixosTests.uptime-kuma;

  meta = {
    description = "Fancy self-hosted monitoring tool";
    homepage = "https://github.com/louislam/uptime-kuma";
    changelog = "https://github.com/louislam/uptime-kuma/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      julienmalka
      felixsinger
    ];

    mainProgram = "uptime-kuma-server";
    # FileNotFoundError: [Errno 2] No such file or directory: 'xcrun'
    broken = stdenv.hostPlatform.isDarwin;
  };
})
