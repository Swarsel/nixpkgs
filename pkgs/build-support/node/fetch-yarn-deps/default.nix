{
  lib,
  stdenv,
  fetchurl,
  cacert,
  callPackage,
  coreutils,
  diffutils,
  fixup-yarn-lock,
  installShellFiles,
  jq,
  makeSetupHook,
  makeWrapper,
  nix-prefetch-git,
  nodejs-slim,
  nodejsInstallExecutables,
  nodejsInstallManuals,
  prefetch-yarn-deps,
  yarn,
}:

let
  yarnpkg-lockfile-tar = fetchurl {
    hash = "sha512-GpSwvyXOcOOlV70vbnzjj4fW5xW/FdUF6nQEt1ENy7m4ZCczi1+/buVUPAqmGfqznsORNFzUMjctTIp8a9tuCQ==";
    url = "https://registry.yarnpkg.com/@yarnpkg/lockfile/-/lockfile-1.1.0.tgz";
  };

  tests = callPackage ./tests { };
in
{
  fetchYarnDeps =
    let
      f =
        {
          hash ? "",
          name ? "offline",
          sha256 ? "",
          src ? null,
          ...
        }@args:
        let
          hash_ =
            if hash != "" then
              {
                outputHash = hash;
                outputHashAlgo = null;
              }
            else if sha256 != "" then
              {
                outputHash = sha256;
                outputHashAlgo = "sha256";
              }
            else
              {
                outputHash = lib.fakeSha256;
                outputHashAlgo = "sha256";
              };
        in
        stdenv.mkDerivation (
          {
            inherit name;

            nativeBuildInputs = [
              prefetch-yarn-deps
              cacert
            ];

            env = {
              GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";
              NODE_EXTRA_CA_CERTS = "${cacert}/etc/ssl/certs/ca-bundle.crt";
            };

            buildPhase = ''
              runHook preBuild

              yarnLock=''${yarnLock:=$PWD/yarn.lock}
              mkdir -p $out
              (cd $out; prefetch-yarn-deps --verbose --builder $yarnLock)

              runHook postBuild
            '';

            dontInstall = true;
            dontUnpack = src == null;
            outputHashMode = "recursive";
          }
          // hash_
          // (removeAttrs args (
            [
              "name"
              "hash"
              "sha256"
            ]
            ++ (lib.optional (src == null) "src")
          ))
        );
    in
    lib.setFunctionArgs f (lib.functionArgs f) // { inherit tests; };

  fixup-yarn-lock = stdenv.mkDerivation {
    pname = "fixup-yarn-lock";
    version = lib.trivial.release;
    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ nodejs-slim ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/libexec

      tar --strip-components=1 -xf ${yarnpkg-lockfile-tar} package/index.js
      mv index.js $out/libexec/yarnpkg-lockfile.js
      cp ${./common.js} $out/libexec/common.js
      cp ${./fixup.js} $out/libexec/fixup.js

      patchShebangs $out/libexec
      makeWrapper $out/libexec/fixup.js $out/bin/fixup-yarn-lock

      runHook postInstall
    '';

    dontBuild = true;
    dontUnpack = true;

    passthru = {
      inherit tests;
    };
  };

  prefetch-yarn-deps = stdenv.mkDerivation {
    pname = "prefetch-yarn-deps";
    version = lib.trivial.release;
    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ nodejs-slim ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/libexec

      tar --strip-components=1 -xf ${yarnpkg-lockfile-tar} package/index.js
      mv index.js $out/libexec/yarnpkg-lockfile.js
      cp ${./common.js} $out/libexec/common.js
      cp ${./index.js} $out/libexec/index.js

      patchShebangs $out/libexec
      makeWrapper $out/libexec/index.js $out/bin/prefetch-yarn-deps \
        --prefix PATH : ${
          lib.makeBinPath [
            coreutils
            nix-prefetch-git
          ]
        }

      runHook postInstall
    '';

    dontBuild = true;
    dontUnpack = true;

    passthru = {
      inherit tests;
    };
  };

  yarnBuildHook = makeSetupHook {
    name = "yarn-build-hook";

    meta = {
      description = "Run yarn build in buildPhase";
      license = lib.licenses.mit;
    };
  } ./yarn-build-hook.sh;

  yarnConfigHook = makeSetupHook {
    propagatedBuildInputs = [
      yarn
      fixup-yarn-lock
    ];

    name = "yarn-config-hook";

    substitutions = {
      # Specify `diff` by abspath to ensure that the user's build
      # inputs do not cause us to find the wrong binaries.
      diff = "${diffutils}/bin/diff";
    };

    meta = {
      description = "Install nodejs dependencies from an offline yarn cache produced by fetchYarnDeps";
      license = lib.licenses.mit;
    };
  } ./yarn-config-hook.sh;

  yarnInstallHook = makeSetupHook {
    propagatedBuildInputs = [
      yarn
      nodejsInstallManuals
      nodejsInstallExecutables
    ];

    name = "yarn-install-hook";

    substitutions = {
      jq = lib.getExe jq;
    };

    meta = {
      description = "Prune yarn dependencies and install files for packages using Yarn 1";
      license = lib.licenses.mit;
    };
  } ./yarn-install-hook.sh;
}
