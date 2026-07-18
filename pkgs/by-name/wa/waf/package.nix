{
  lib,
  stdenv,
  fetchFromGitLab,
  callPackage,
  ensureNewerSourcesForZipFilesHook,
  makeWrapper,
  python3,
  # optional list of extra waf tools, e.g. `[ "doxygen" "pytest" ]`
  extraTools ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "waf";
  version = "2.1.9";

  src = fetchFromGitLab {
    owner = "ita1024";
    repo = "waf";
    rev = "waf-${finalAttrs.version}";
    hash = "sha256-myPGbJW/RkOtEas+qZ/vTL66bekwDBPhC6AmfXECkcw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ensureNewerSourcesForZipFilesHook
    python3
    makeWrapper
  ];

  buildInputs = [
    # waf executable uses `#!/usr/bin/env python`
    python3
  ];

  buildPhase =
    let
      extraToolsList = lib.optionalString (
        extraTools != [ ]
      ) "--tools=\"${lib.concatStringsSep "," extraTools}\"";
    in
    ''
      runHook preBuild

      python waf-light build ${extraToolsList}

      substituteInPlace waf \
        --replace "w = test(i + '/lib/' + dirname)" \
                  "w = test('$out/${python3.sitePackages}')"

      runHook postBuild
    '';

  installPhase = ''
    runHook preInstall

    install -D waf "$out"/bin/waf
    wrapProgram "$out"/bin/waf --prefix PYTHONPATH : "$out"/${python3.sitePackages}
    mkdir -p "$out"/${python3.sitePackages}/
    cp -r waflib "$out"/${python3.sitePackages}/
    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    python waf-light configure

    runHook postConfigure
  '';

  passthru = {
    inherit python3 extraTools;

    hook = callPackage ./hook.nix {
      waf = finalAttrs.finalPackage;
    };
  };

  meta = {
    inherit (python3.meta) platforms;
    description = "Meta build system";
    homepage = "https://waf.io";
    changelog = "https://gitlab.com/ita1024/waf/blob/waf-${finalAttrs.version}/ChangeLog";
    license = lib.licenses.bsd3;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ ];
    mainProgram = "waf";
  };
})
