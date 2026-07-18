{
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm_11,
}:

let
  pnpm = pnpm_11;

  inherit (import ./sources.nix { inherit fetchFromGitHub; })
    pname
    version
    src
    pnpmDepsHash
    ;
in
stdenv.mkDerivation (finalAttrs: {
  inherit src version;
  pname = "${pname}-web";

  postPatch = ''
    NL=$'\n'
    LINE_BEFORE_HOST='allowedHosts: ["login.example.com", ...allowedHosts],'

    substituteInPlace ./vite.config.ts \
      --replace-fail 'outDir: "../internal/server/public_html"' 'outDir: "dist"' \
      --replace-fail "$LINE_BEFORE_HOST" "$LINE_BEFORE_HOST$NL"'            host: "127.0.0.1",'
  '';

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  postBuild = ''
    pnpm run build
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    mv dist $out/share/authelia-web

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;

    inherit pnpm; # This may be different than pkgs.pnpm
    fetcherVersion = 4;
    hash = pnpmDepsHash;
  };

  sourceRoot = "${finalAttrs.src.name}/web";
  # (node:24500) Warning: File descriptor 19 closed but not opened in unmanaged mode
  # (node:24500) Warning: File descriptor 19 opened in unmanaged mode twice
  meta.broken = stdenv.hostPlatform.isDarwin;
})
