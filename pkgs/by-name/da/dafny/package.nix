{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dafny,
  dotnetCorePackages,
  jdk11,
  runCommand,
  writeScript,
  z3,
}:

let
  examples = fetchFromGitHub {
    hash = "sha256-Ng5wve/4gQr/2hsFWUFFcTL3K2xH7dP9w8IrmvWMKyg=";
    owner = "gaberch";
    repo = "Various-Algorithms-Verified-With-Dafny";
    rev = "50e451bbcd15e52e27d5bbbf66b0b4c4abbff41c";
  };

  tests = {
    verify = runCommand "dafny-test" { } ''
      mkdir $out
      cp ${examples}/SlowMax.dfy $out
      ${dafny}/bin/dafny verify --allow-warnings $out/SlowMax.dfy
    '';

    # Broken, cannot compile generated .cs files for now
    #run = runCommand "dafny-test" { } ''
    #    mkdir $out
    #    cp ${examples}/SlowMax.dfy $out
    #    ${dafny}/bin/dafny run --allow-warnings $out/SlowMax.dfy
    #  '';

    # TODO: Ensure then tests that dafny can generate to and compile other
    # languages (Java, Cpp, etc.)
  };
in
buildDotnetModule rec {
  pname = "Dafny";
  version = "4.11.0";

  src = fetchFromGitHub {
    owner = "dafny-lang";
    repo = "dafny";
    tag = "v${version}";
    hash = "sha256-oM8dKDZ5FCmKq24taQ6Sr2eTeNAMSq8MY0U1AFvS6D4=";
  };

  postPatch = ''
    cp ${writeScript "fake-gradlew-for-dafny" ''
      mkdir -p build/libs/
      javac $(find -name "*.java" | grep "^./src/main") -d classes
      jar cf build/libs/DafnyRuntime-${version}.jar -C classes dafny
    ''} Source/DafnyRuntime/DafnyRuntimeJava/gradlew

    # Needed to fix
    # "error NETSDK1129: The 'Publish' target is not supported without
    # specifying a target framework. The current project targets multiple
    # frameworks, you must specify the framework for the published
    # application."
    substituteInPlace Source/DafnyRuntime/DafnyRuntime.csproj \
      --replace-fail TargetFrameworks TargetFramework \
      --replace-fail "netstandard2.0;net452" net8.0
  '';

  nativeBuildInputs = [ jdk11 ];

  postFixup = ''
    ln -s "$out/bin/Dafny" "$out/bin/dafny" || true
  '';

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ "Dafny" ];

  # Help Dafny find z3 and dotnet SDK (needed for dafny run)
  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        z3
        dotnet-sdk
      ]
    }"
  ];

  nugetDeps = ./deps.json;

  # Build just these projects. Building Source/Dafny.sln includes a bunch of
  # unnecessary components like tests.
  projectFile = [
    "Source/Dafny/Dafny.csproj"
    "Source/DafnyRuntime/DafnyRuntime.csproj"
    "Source/DafnyLanguageServer/DafnyLanguageServer.csproj"
  ];

  passthru.tests = tests;

  meta = {
    description = "Programming language with built-in specification constructs";
    homepage = "https://research.microsoft.com/dafny";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ layus ];
    platforms = with lib.platforms; (linux ++ darwin);
  };
}
