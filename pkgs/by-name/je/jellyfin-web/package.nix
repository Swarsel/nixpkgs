{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  giflib,
  jellyfin,
  nix-update-script,
  nodejs_22,
  pango,
  pkg-config,
  xcbuild,
}:
buildNpmPackage (finalAttrs: {
  pname = "jellyfin-web";
  version = "10.11.11";

  src =
    assert finalAttrs.version == jellyfin.version;
    fetchFromGitHub {
      owner = "jellyfin";
      repo = "jellyfin-web";
      tag = "v${finalAttrs.version}";
      hash = "sha256-3Gyg0eSbOXO0wgdgzuOtD8nDmSM37z7Bc0fKcbo9ffA=";
    };

  postPatch = ''
    substituteInPlace webpack.common.js \
      --replace-fail "git describe --always --dirty" "echo ${finalAttrs.src.rev}"
  '';

  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ xcbuild ];

  buildInputs = [
    pango
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    giflib
  ];

  npmDepsHash = "sha256-4kZo50xY/SvjpHToeIt0E91yeM7ab6Q6XtBMU5zSrF4=";

  preBuild = ''
    # using sass-embedded fails at executing node_modules/sass-embedded-linux-x64/dart-sass/src/dart
    rm -r node_modules/sass-embedded*
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -a dist $out/share/jellyfin-web

    runHook postInstall
  '';

  nodejs = nodejs_22;
  npmBuildScript = [ "build:production" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Web Client for Jellyfin";
    homepage = "https://jellyfin.org/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      nyanloutre
      minijackson
      purcell
      jojosch
    ];
  };
})
