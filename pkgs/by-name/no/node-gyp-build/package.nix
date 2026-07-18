{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  nodejs,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "node-gyp-build";
  version = "4.8.4";

  src = fetchFromGitHub {
    owner = "prebuild";
    repo = "node-gyp-build";
    tag = "v${finalAttrs.version}";
    hash = "sha256-65EQGGpwL0C8AOhFyf62nVEt4e2pCS0lAv+20kt3Zdk=";
  };

  buildInputs = [
    nodejs
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/node-gyp-build
    mkdir -p $out/bin

    chmod +x ./{bin,build-test,optional}.js
    mv *.js package.json $out/lib/node_modules/node-gyp-build

    ln -s $out/lib/node_modules/node-gyp-build/bin.js $out/bin/node-gyp-build
    ln -s $out/lib/node_modules/node-gyp-build/optional.js $out/bin/node-gyp-build-optional
    ln -s $out/lib/node_modules/node-gyp-build/build-test.js $out/bin/node-gyp-build-test
  '';

  dontBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Build tool and bindings loader for node-gyp that supports prebuilds";
    homepage = "https://github.com/prebuild/node-gyp-build";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "node-gyp-build";
  };
})
