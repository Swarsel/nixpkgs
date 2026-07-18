{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  makeWrapper,
  mystmd,
  nix-update-script,
  nodejs,
  testers,
  writableTmpDirAsHomeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mystmd";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "jupyter-book";
    repo = "mystmd";
    tag = "mystmd@${finalAttrs.version}";
    hash = "sha256-SopL2yIFWWCMm7afjkMrG4Z7Ohxxb5gfCrKNRX5tyo8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    bun
    nodejs
    makeWrapper
  ];

  buildInputs = [
    nodejs
  ];

  buildPhase = ''
    runHook preBuild

    cp -R ${finalAttrs.node_modules}/node_modules .
    patchShebangs node_modules
    bun run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -r node_modules $out/lib/
    cp -r packages $out/lib/
    install -D packages/mystmd/dist/myst.cjs $out/bin/myst
    wrapProgram $out/bin/myst --prefix PATH : ${lib.makeBinPath [ nodejs ]}
    runHook postInstall
  '';

  __structuredAttrs = true;

  node_modules = stdenv.mkDerivation {
    inherit (finalAttrs) src version;
    pname = "${finalAttrs.pname}-node_modules";

    nativeBuildInputs = [
      bun
      nodejs
      writableTmpDirAsHomeHook
      makeWrapper
    ];

    buildPhase = ''
      runHook preBuild
      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install --no-progress --frozen-lockfile --no-cache

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/node_modules
      cp -R ./node_modules $out

      runHook postInstall
    '';

    dontConfigure = true;
    dontFixup = true;

    outputHash =
      {
        aarch64-darwin = "sha256-ZUx+jF7IcEbUCnUUeW0uOFgEpO9UIJpP3/VpUJ5ulAM=";
        aarch64-linux = "sha256-xm4T1BL3AyRsYOERz4LhG4ZJQkSMzspoA+l60OND3E0=";
        x86_64-linux = "sha256-4EQkvsoji9M4VCrdwyHm+ncd4XFjgAf34Kt+YeM3qjs=";
      }
      .${stdenv.hostPlatform.system} or (throw "unsupported system ${stdenv.hostPlatform.system}");

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Command line tools for working with MyST Markdown";
    homepage = "https://github.com/jupyter-book/mystmd";
    changelog = "https://github.com/jupyter-book/mystmd/blob/${finalAttrs.src.rev}/packages/myst-cli/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tbutter ];
    mainProgram = "myst";
  };
})
