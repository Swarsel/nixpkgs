{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tailwindcss-language-server";
  version = "0.14.29";

  src = fetchFromGitHub {
    owner = "tailwindlabs";
    repo = "tailwindcss-intellisense";
    tag = "v${finalAttrs.version}";
    hash = "sha256-o5NyU52j3ZyuKWT4lL5U78qz4TBbXerylTl2fdvwqlk=";
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_10
  ];

  buildInputs = [
    nodejs
  ];

  # Must build the "@tailwindcss/language-service" package. Dependency is linked via workspace by "pnpm"
  # https://github.com/tailwindlabs/tailwindcss-intellisense/blob/v0.14.24/pnpm-lock.yaml#L71
  buildPhase = ''
    runHook preBuild

    pnpm --filter "@tailwindcss/language-server..." build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/tailwindcss-language-server}
    cp -r {packages,node_modules} $out/lib/tailwindcss-language-server
    chmod +x $out/lib/tailwindcss-language-server/packages/tailwindcss-language-server/bin/tailwindcss-language-server
    ln -s $out/lib/tailwindcss-language-server/packages/tailwindcss-language-server/bin/tailwindcss-language-server $out/bin/tailwindcss-language-server

    runHook postInstall
  '';

  patchPhase = ''
    substituteInPlace ./packages/tailwindcss-language-server/package.json \
      --replace '"@tailwindcss/oxide": "^4.1.15",' '"@tailwindcss/oxide": "^4.1.14",'
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      patchPhase
      ;

    fetcherVersion = 4;
    hash = "sha256-excPYLP+81ftU/LwBeO/lmj4Nbefb4dNvpvudg/sx+w=";
    pnpm = pnpm_10;
  };

  pnpmWorkspaces = [
    "@tailwindcss/language-server..."
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tailwind CSS Language Server";
    homepage = "https://github.com/tailwindlabs/tailwindcss-intellisense";
    changelog = "https://github.com/tailwindlabs/tailwindcss-intellisense/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
    platforms = nodejs.meta.platforms;
    mainProgram = "tailwindcss-language-server";
  };
})
