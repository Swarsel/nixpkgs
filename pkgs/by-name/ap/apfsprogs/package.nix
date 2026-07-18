{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  testers,
}:
let
  tools = [
    "apfsck"
    "apfs-label"
    "apfs-snap"
    "mkapfs"
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "apfsprogs";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "linux-apfs";
    repo = "apfsprogs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GhhuielfFvcpe9hL3fUcg2xlwFrzjiUS/ZLn0jkfkh8=";
  };

  postPatch = ''
    substituteInPlace \
      apfs-snap/Makefile apfsck/Makefile mkapfs/Makefile apfs-label/Makefile \
      --replace-fail \
        '$(shell git describe --always HEAD | tail -c 9)' \
        'v${finalAttrs.version}'
  '';

  strictDeps = true;

  buildPhase = ''
    runHook preBuild
    make -C apfs-snap $makeFlags
    make -C apfsck $makeFlags
    make -C mkapfs $makeFlags
    make -C apfs-label $makeFlags
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make -C apfs-snap install DESTDIR="$out" $installFlags
    make -C apfsck install DESTDIR="$out" $installFlags
    make -C mkapfs install DESTDIR="$out" $installFlags
    make -C apfs-label install DESTDIR="$out" $installFlags
    runHook postInstall
  '';

  passthru.tests =
    let
      mkVersionTest = tool: {
        "version-${tool}" = testers.testVersion {
          version = "v${finalAttrs.version}";
          command = "${tool} -v";
          package = finalAttrs.finalPackage;
        };
      };
      versionTestList = map mkVersionTest tools;

      versionTests = lib.mergeAttrsList versionTestList;
    in
    {
      apfs = nixosTests.apfs;
    }
    // versionTests;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Experimental APFS tools for linux";
    homepage = "https://github.com/linux-apfs/apfsprogs";
    changelog = "https://github.com/linux-apfs/apfsprogs/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Luflosi ];
    platforms = lib.platforms.linux;
  };
})
