{
  lib,
  stdenv,
  fetchFromGitHub,
  bintools,
  buildDotnetModule,
  dotnetCorePackages,
  git,
  glibcLocales,
  mono,
  nix-update-script,
}:
let
  mainProgram = "EventStore.ClusterNode";
in

buildDotnetModule rec {
  pname = "EventStore";
  version = "24.10.6";

  src = fetchFromGitHub {
    owner = "kurrent-io";
    repo = "KurrentDB";
    tag = "v${version}";
    hash = "sha256-8/sagvMyJ1/onGMuJ28QLWI5M8dBDWyGOcZKUv3PJsQ=";
    leaveDotGit = true;
  };

  nativeBuildInputs = [
    git
    glibcLocales
    bintools
  ];

  # Fixes application reporting 0.0.0.0 as its version.
  env.MINVERVERSIONOVERRIDE = version;
  doCheck = true;
  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/EventStore.ClusterNode --insecure \
      --db "$HOME/data" \
      --index "$HOME/index" \
      --log "$HOME/log" \
      -runprojections all --startstandardprojections \
      --EnableAtomPubOverHttp &

    PID=$!

    sleep 30s;
    kill "$PID";
  '';

  # This test has a problem running on macOS
  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    "EventStore.Projections.Core.Tests.Services.grpc_service.ServerFeaturesTests<LogFormat+V2,String>.should_receive_expected_endpoints"
    "EventStore.Projections.Core.Tests.Services.grpc_service.ServerFeaturesTests<LogFormat+V3,UInt32>.should_receive_expected_endpoints"
  ];

  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ mainProgram ];
  nugetDeps = ./deps.json;
  projectFile = "src/EventStore.ClusterNode/EventStore.ClusterNode.csproj";
  runtimeDeps = [ mono ];
  testProjectFile = "src/EventStore.Projections.Core.Tests/EventStore.Projections.Core.Tests.csproj";
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit mainProgram;
    description = "Event sourcing database with processing logic in JavaScript";
    homepage = "https://geteventstore.com/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      puffnfresh
      mdarocha
    ];

    platforms = [
      "x86_64-linux"
    ];
  };
}
