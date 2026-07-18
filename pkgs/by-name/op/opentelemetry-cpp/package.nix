{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  grpc,
  gtest,
  nix-update-script,
  nlohmann_json,
  # for passthru.tests
  opentelemetry-cpp,
  prometheus-cpp,
  protobuf,
  cxxStandard ? null,
  enableElasticSearch ? false,
  enableGrpc ? false,
  enableHttp ? false,
  enablePrometheus ? false,
  enableZipkin ? false,
}:
let
  opentelemetry-proto = fetchFromGitHub {
    hash = "sha256-RJrS0C4GZfUdETff+ZlbJr67Z+JObrLsDvyGqobf4UI=";
    owner = "open-telemetry";
    repo = "opentelemetry-proto";
    rev = "v1.10.0";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "opentelemetry-cpp";
  version = "1.27.0";

  src = fetchFromGitHub {
    owner = "open-telemetry";
    repo = "opentelemetry-cpp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7G9uHMlV7/rHvD/g+ktxT6RTfDRSfsXQO7QHk26XVKs=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./0001-Disable-tests-requiring-network-access.patch
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin ./0002-Disable-segfaulting-test-on-Darwin.patch;

  strictDeps = true;
  nativeBuildInputs = [ cmake ];

  buildInputs = [
    curl
    nlohmann_json
  ];

  propagatedBuildInputs =
    lib.optionals (enableGrpc || enableHttp) [ protobuf ]
    ++ lib.optionals enableGrpc [
      grpc
    ]
    ++ lib.optionals enablePrometheus [
      prometheus-cpp
    ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "WITH_BENCHMARK" false)
    (lib.cmakeBool "WITH_OTLP_HTTP" enableHttp)
    (lib.cmakeBool "WITH_OTLP_GRPC" enableGrpc)
    (lib.cmakeBool "WITH_PROMETHEUS" enablePrometheus)
    (lib.cmakeBool "WITH_ELASTICSEARCH" enableElasticSearch)
    (lib.cmakeBool "WITH_ZIPKIN" enableZipkin)
    (lib.cmakeFeature "OTELCPP_PROTO_PATH" "${opentelemetry-proto}")
  ]
  ++ lib.optionals (cxxStandard != null) [
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" cxxStandard)
    (lib.cmakeFeature "WITH_STL" "CXX${cxxStandard}")
  ];

  doCheck = true;

  checkInputs = [
    gtest
  ];

  # "--replace-fail" would normally be preferred, since it is better at
  # highlighting obsolete/uneeded substitutions, but in this case
  # "--replace-quiet" must be used.
  # substituteInPlace with "--replace-fail" already fails if there is no
  # substitution in at least one of the specified files. Below is applied to
  # multiple files where some but not all of them match the substitution
  # strings.
  postInstall = ''
    substituteInPlace $out/lib/cmake/opentelemetry-cpp/opentelemetry-cpp*-target.cmake \
      --replace-quiet "\''${_IMPORT_PREFIX}/include" "$dev/include"
  '';

  passthru.tests = {
    # Unfortunately there is no such thing as finalAttrs.finalPackage.override,
    # so we have to resort to this.
    full = opentelemetry-cpp.override {
      enableElasticSearch = true;
      enableGrpc = true;
      enableHttp = true;
      enablePrometheus = true;
      enableZipkin = true;
    };
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OpenTelemetry C++ Client Library";
    homepage = "https://github.com/open-telemetry/opentelemetry-cpp";
    license = [ lib.licenses.asl20 ];

    maintainers = with lib.maintainers; [
      jfroche
      panicgh
    ];

    platforms = lib.platforms.all;
    # https://github.com/protocolbuffers/protobuf/issues/14492
    broken = !(stdenv.buildPlatform.canExecute stdenv.hostPlatform);
  };
})
