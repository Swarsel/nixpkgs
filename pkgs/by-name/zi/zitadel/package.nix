{
  lib,
  stdenv,
  fetchFromGitHub,
  buf,
  buildGoModule,
  cacert,
  callPackage,
  grpc-gateway,
  protoc-gen-go,
  protoc-gen-go-grpc,
  protoc-gen-validate,
  sass,
  statik,
}:

let
  version = "2.71.7";
  zitadelRepo = fetchFromGitHub {
    hash = "sha256-0ZOiwJ/ehDBkbd7iTTyVJzLj6Etph5/oxrDrck30ZL8=";
    owner = "zitadel";
    repo = "zitadel";
    rev = "v${version}";
  };
  goModulesHash = "sha256-iZCjHSpQ7Gy41Dd4svRLbyEh1N8VE8U0uCOlN9rfJQU=";

  buildZitadelProtocGen =
    name:
    buildGoModule {
      inherit version;
      pname = "protoc-gen-${name}";
      src = zitadelRepo;
      vendorHash = goModulesHash;

      buildPhase = ''
        go install internal/protoc/protoc-gen-${name}/main.go
      '';

      postInstall = ''
        mv $out/bin/main $out/bin/protoc-gen-${name}
      '';

      proxyVendor = true;
    };

  protoc-gen-authoption = buildZitadelProtocGen "authoption";
  protoc-gen-zitadel = buildZitadelProtocGen "zitadel";

  # Buf downloads dependencies from an external repo - there doesn't seem to
  # really be any good way around it. We'll use a fixed-output derivation so it
  # can download what it needs, and output the relevant generated code for use
  # during the main build.
  generateProtobufCode =
    {
      hash,
      outputPath,
      pname,
      version,
      bufArgs ? "",
      nativeBuildInputs ? [ ],
      workDir ? ".",
    }:
    stdenv.mkDerivation {
      inherit version;
      pname = "${pname}-buf-generated";
      src = zitadelRepo;
      patches = [ ./console-use-local-protobuf-plugins.patch ];

      nativeBuildInputs = nativeBuildInputs ++ [
        buf
        cacert
      ];

      buildPhase = ''
        cd ${workDir}
        HOME=$TMPDIR buf generate ${bufArgs}
      '';

      installPhase = ''
        cp -r ${outputPath} $out
      '';

      outputHash = hash;
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };

  protobufGenerated = generateProtobufCode {
    inherit version;
    pname = "zitadel";

    nativeBuildInputs = [
      grpc-gateway
      protoc-gen-authoption
      protoc-gen-go
      protoc-gen-go-grpc
      protoc-gen-validate
      protoc-gen-zitadel
    ];

    hash = "sha256-rc5A2bQ2iWkybprQ7IWsQ/LLAQxPqhlxzVvPn8Ec56E=";
    outputPath = ".artifacts";
  };
in
buildGoModule rec {
  inherit version;
  pname = "zitadel";
  src = zitadelRepo;

  nativeBuildInputs = [
    sass
    statik
  ];

  vendorHash = goModulesHash;

  # Adapted from Makefile in repo, with dependency fetching and protobuf codegen
  # bits removed
  preBuild = ''
    mkdir -p pkg/grpc
    cp -r ${protobufGenerated}/grpc/github.com/zitadel/zitadel/pkg/grpc/* pkg/grpc
    mkdir -p openapi/v2/zitadel
    cp -r ${protobufGenerated}/grpc/zitadel/ openapi/v2/zitadel

    go generate internal/api/ui/login/static/resources/generate.go
    go generate internal/api/ui/login/statik/generate.go
    go generate internal/notification/statik/generate.go
    go generate internal/statik/generate.go

    mkdir -p docs/apis/assets
    go run internal/api/assets/generator/asset_generator.go -directory=internal/api/assets/generator/ -assets=docs/apis/assets/assets.md

    cp -r ${passthru.console}/* internal/api/ui/console/static
  '';

  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 $GOPATH/bin/zitadel $out/bin/
  '';

  ldflags = [ "-X 'github.com/zitadel/zitadel/cmd/build.version=${version}'" ];
  proxyVendor = true;

  passthru = {
    console = callPackage (import ./console.nix {
      inherit generateProtobufCode version zitadelRepo;
    }) { };
  };

  meta = {
    description = "Identity and access management platform";
    homepage = "https://zitadel.com/";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.nrabulinski ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    downloadPage = "https://github.com/zitadel/zitadel/releases";
  };
}
