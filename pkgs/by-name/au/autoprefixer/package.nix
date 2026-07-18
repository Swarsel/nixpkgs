{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "autoprefixer";
  version = "10.5.0";

  src = fetchFromGitHub {
    owner = "postcss";
    repo = "autoprefixer";
    tag = finalAttrs.version;
    hash = "sha256-s152v9sIuQLvhfPsZvQa+O9UhoASgm/e8dnz0t4pP3A=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_10
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    mv bin/ $out
    mv lib/ $out
    mv node_modules/ $out
    mv data/ $out
    mv package.json $out

    runHook postInstall
  '';

  postFixup = ''
    patchShebangs $out/bin/autoprefixer
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-Sxt4vtdlMdXxXqt22hfZJskj8mkB5t85IZ5BsbCoDF4=";
    pnpm = pnpm_10;
  };

  passthru = {
    tests = {
      simple-execution = callPackage ./tests/simple-execution.nix { };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Parse CSS and add vendor prefixes to CSS rules using values from the Can I Use website";
    homepage = "https://github.com/postcss/autoprefixer";
    changelog = "https://github.com/postcss/autoprefixer/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.skohtv ];
    mainProgram = "autoprefixer";
  };
})
