{
  lib,
  fetchFromGitHub,
  buildGoModule,
  grype,
  makeBinaryWrapper,
  nix-update-script,
  syft,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "bomly";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "bomly-dev";
    repo = "bomly-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RJqYRCnE4lqR68lP9hL9hTOxXS3cPEgspBn2JgvffyM=";
  };

  # .gitattributes excludes all testdata from the GitHub tarball
  postPatch = ''
    mkdir -p internal/benchmark/testdata
    cp ${./scan_targets.json} internal/benchmark/testdata/scan_targets.json
  '';

  buildInputs = [ makeBinaryWrapper ];
  vendorHash = "sha256-W7FfqWV86D8fXZ4nm/0IVZuqocgo8/Sd9DA1Ef4SJ/4=";
  # testdata directories are excluded from the GitHub tarball via .gitattributes
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = ''
    wrapProgram $out/bin/bomly --prefix PATH : "${
      lib.makeBinPath [
        grype
        syft
      ]
    }"
  '';

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-X=main.version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for dependency intelligence, SBOMs, vulnerability auditing, and CI policy gates";
    homepage = "https://github.com/bomly-dev/bomly-cli";
    changelog = "https://github.com/bomly-dev/bomly-cli/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "bomly";
  };
})
