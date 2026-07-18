{
  lib,
  bash,
  bluesky-pds,
  curl,
  jq,
  makeBinaryWrapper,
  openssl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (bluesky-pds) version src;
  pname = "pdsadmin";
  patches = [ ./pdsadmin-offline.patch ];
  strictDeps = true;
  nativeBuildInputs = [ makeBinaryWrapper ];
  buildInputs = [ bash ];

  buildPhase = ''
    runHook preBuild

    substituteInPlace pdsadmin.sh \
      --replace-fail NIXPKGS_PDSADMIN_ROOT $out

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 pdsadmin.sh $out/lib/pds/pdsadmin.sh
    install -Dm755 pdsadmin/*.sh $out/lib/pds
    makeWrapper "$out/lib/pds/pdsadmin.sh" "$out/bin/pdsadmin" \
      --prefix PATH : "${
        lib.makeBinPath [
          jq
          curl
          openssl
        ]
      }"

    runHook postInstall
  '';

  meta = {
    inherit (bluesky-pds.meta) homepage license;
    description = "Admin scripts for Bluesky Personal Data Server (PDS)";
    maintainers = with lib.maintainers; [ t4ccer ];
    platforms = lib.platforms.unix;
    mainProgram = "pdsadmin";
  };
})
