{
  buildNpmPackage,
  fetchNpmDeps,
  fetchpatch,
  meta,
  src,
  version,
}:
buildNpmPackage (finalAttrs: {
  inherit src version;
  pname = "lasuite-meet-frontend";

  patches = [
    # backport build fix
    # FIXME: remove in next release
    (fetchpatch {
      hash = "sha256-1A26T6LtFlOiJNVGD/fZs562feoQXY37A2ecUfvDGpk=";

      includes = [
        "package.json"
        "package-lock.json"
      ];

      stripLen = 2;
      url = "https://github.com/suitenumerique/meet/commit/df1495c97bc913866169ee8875a9a3169fcfc87e.diff";
    })
  ];

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  npmBuildScript = "build";

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs)
      version
      src
      patches
      sourceRoot
      ;

    hash = "sha256-uiD5pcpmka43uraMFo7lRuQFx/4aq1BEhQvyCAzo8fg=";
  };

  sourceRoot = "${finalAttrs.src.name}/src/frontend";

  meta = meta // {
    description = "Open source alternative to Google Meet and Zoom powered by LiveKit: HD video calls, screen sharing, and chat features. Built with Django and React";
  };
})
