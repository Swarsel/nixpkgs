{
  buildNpmPackage,
  fetchNpmDeps,
  libsecret,
  meta,
  pkg-config,
  src,
  version,
}:
buildNpmPackage (finalAttrs: {
  inherit src version;
  pname = "lasuite-meet-addon-outlook";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libsecret
  ];

  installPhase = ''
    runHook preInstall

    cp -r dist $out
    cp manifest.xml $out

    runHook postInstall
  '';

  npmBuildScript = "build";

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) version src sourceRoot;
    hash = "sha256-1CoY0A4KMdn76SbgfRULn+O4yZhJgwNdk/bZ9Fk2rwY=";
  };

  sourceRoot = "${finalAttrs.src.name}/src/addons/outlook";

  meta = meta // {
    description = "Microsoft Outlook add-in support for LaSuite Meet";
  };
})
