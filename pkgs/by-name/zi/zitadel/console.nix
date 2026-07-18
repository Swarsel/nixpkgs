{
  generateProtobufCode,
  version,
  zitadelRepo,
}:

{
  stdenv,
  fetchYarnDeps,
  grpc-gateway,
  nodejs,
  protoc-gen-grpc-web,
  protoc-gen-js,
  yarnBuildHook,
  yarnConfigHook,
}:

let
  protobufGenerated = generateProtobufCode {
    inherit version;
    pname = "zitadel-console";

    nativeBuildInputs = [
      grpc-gateway
      protoc-gen-grpc-web
      protoc-gen-js
    ];

    bufArgs = "../proto --include-imports --include-wkt";
    hash = "sha256-UzmwUUYg0my3noAQNtlUEBQ+K6GVnBSkWj4CzoaoLKw=";
    outputPath = "src/app/proto";
    workDir = "console";
  };
in
stdenv.mkDerivation {
  inherit version;
  pname = "zitadel-console";
  src = zitadelRepo;

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
  ];

  preBuild = ''
    cp -r ${protobufGenerated} src/app/proto
  '';

  installPhase = ''
    runHook preInstall
    cp -r dist/console "$out"
    runHook postInstall
  '';

  offlineCache = fetchYarnDeps {
    hash = "sha256-ekgLd5DTOBZWuT63QnTjx40ZYvLKZh+FXCn+h5vj9qQ=";
    yarnLock = "${zitadelRepo}/console/yarn.lock";
  };

  sourceRoot = "${zitadelRepo.name}/console";
}
