{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  esbuild,
  fetchPnpmDeps,
  fetchgit,
  gitMinimal,
  jq,
  nodejs-slim_24,
  pnpmConfigHook,
  pnpm_11,
  python3,
  removeReferencesTo,
  srcOnly,
  zip,
}:
let
  nodeSources = srcOnly nodejs-slim_24;
  pnpm' = pnpm_11.override { nodejs-slim = nodejs-slim_24; };
  esbuild' = esbuild.override {
    buildGoModule =
      args:
      buildGoModule (
        args
        // rec {
          version = "0.19.9";

          src = fetchFromGitHub {
            owner = "evanw";
            repo = "esbuild";
            rev = "v${version}";
            hash = "sha256-GiQTB/P+7uVGZfUaeM7S/5lGvfHlTl/cFt7XbNfE0qw=";
          };

          vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
        }
      );
  };
  customPython = python3.withPackages (p: [ p.setuptools ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "taler-wallet-core";
  version = "1.5.10";

  # NOTE: we have to use the tag's commit, else:
  # > fatal: Not a valid object name
  # > Unrecognized git object type:
  # > Unable to checkout refs/tags/v1.5.10 from https://git-www.taler.net/taler-typescript-core.git.
  src = fetchgit {
    url = "https://git-www.taler.net/taler-typescript-core.git";
    rev = "3816d089724c513299b62b20bdb88d94d5be67f5";
    hash = "sha256-/KxB4uBbJbnFUPAc6a++bfTwl2CM1ZYjxPTDYwRh21Q=";
  };

  postPatch = ''
    patchShebangs packages/*/*.mjs
    substituteInPlace pnpm-lock.yaml \
      --replace-fail "esbuild: 0.12.29" "esbuild: ${esbuild'.version}"
  '';

  nativeBuildInputs = [
    customPython
    nodejs-slim_24
    nodejs-slim_24.npm
    pnpmConfigHook
    pnpm'
    gitMinimal
    jq
    zip
  ];

  buildInputs = [
    nodejs-slim_24
  ];

  env.ESBUILD_BINARY_PATH = lib.getExe esbuild';

  preConfigure = ''
    ./bootstrap
  '';

  # After the pnpm configure, we need to build the binaries of all instances
  # of better-sqlite3. It has a native part that it wants to build using a
  # script which is disallowed.
  preBuild = ''
    for f in $(find -path '*/node_modules/better-sqlite3' -type d); do
      (cd "$f" && (
      npm run build-release --offline --nodedir="${nodeSources}"
      find build -type f -exec \
        ${lib.getExe removeReferencesTo} \
        -t "${nodeSources}" {} \;
      ))
    done
  '';

  postFixup = ''
    # else it fails to find the python interpreter
    patchShebangs --build $out/bin/taler-helper-sqlite3
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-ZoxAZ5f3Szz2goGOE5yn/aCZ5fuhDt1owZ/o1kvX7d0=";
    pnpm = pnpm';
  };

  # Make a fake git repo with a commit.
  # Without this, the package does not build.
  postUnpack = ''
    git init -b master
    git config user.email "root@localhost"
    git config user.name "root"
    git commit --allow-empty -m "Initial commit"
  '';

  meta = {
    description = "CLI wallet for GNU Taler written in TypeScript and Anastasis Web UI";
    homepage = "https://git-www.taler.net/taler-typescript-core.git";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "taler-wallet-cli";
    # ./configure doesn't understand --build / --host
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
    teams = [ lib.teams.ngi ];
  };
})
