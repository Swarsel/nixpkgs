{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  buildPackages,
  dotnetCorePackages,
  fetchNpmDeps,
  mono,
  nix-update-script,
  nodejs_24,
  slskd,
  testers,
}:

let
  nodejs = nodejs_24;
  # https://github.com/NixOS/nixpkgs/blob/d88947e91716390bdbefccdf16f7bebcc41436eb/pkgs/build-support/node/build-npm-package/default.nix#L62
  npmHooks = buildPackages.npmHooks.override { inherit nodejs; };
in
buildDotnetModule rec {
  pname = "slskd";
  version = "0.24.5";

  src = fetchFromGitHub {
    owner = "slskd";
    repo = "slskd";
    tag = version;
    hash = "sha256-B0LAd9Fn1E5heGPk5dd7DoHWreHRxe42Xew5PmLId7g=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  postBuild = ''
    pushd "$npmRoot"
    npm run build --legacy-peer-deps
    popd
  '';

  doCheck = true;

  postInstall = ''
    rm -r $out/lib/slskd/wwwroot
    mv "$npmRoot"/build $out/lib/slskd/wwwroot
  '';

  disabledTests = [
    # Random failures on OfBorg, cause unknown
    "slskd.Tests.Unit.Transfers.Uploads.UploadGovernorTests+ReturnBytes.Returns_Bytes_To_Bucket"
  ];

  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-hmN91Y9ePJ7ZUyQX8jJbOgf0SuhsgmhO1ifi4sWhPUM=";
    name = "${pname}-${version}-npm-deps";
    sourceRoot = "${src.name}/${npmRoot}";
  };

  npmRoot = "src/web";
  nugetDeps = ./deps.json;
  projectFile = "slskd.sln";
  runtimeDeps = [ mono ];
  testProjectFile = "tests/slskd.Tests.Unit/slskd.Tests.Unit.csproj";

  passthru = {
    tests.version = testers.testVersion { package = slskd; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Modern client-server application for the Soulseek file sharing network";
    homepage = "https://github.com/slskd/slskd";
    changelog = "https://github.com/slskd/slskd/releases/tag/${version}";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      ppom
      melvyn2
      getchoo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "slskd";
  };
}
