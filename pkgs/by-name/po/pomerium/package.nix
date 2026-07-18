{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
  nixosTests,
  pomerium-cli,
  runCommand,
}:

let
  inherit (lib)
    concatStringsSep
    concatMap
    id
    mapAttrsToList
    ;

  version = "0.32.9";
  src = fetchFromGitHub {
    owner = "pomerium";
    repo = "pomerium";
    rev = "v${version}";
    hash = "sha256-TGsbAAGt0nvARgMrYMMFEUA24I0z8aOeB9p2y5FhU3I=";
  };
  vendorHash = "sha256-R5YSMHTaBKzHzrVm586QYeMqc6hILr8CLjp1QDupyGY=";

  getEnvoy = buildGoModule {
    inherit src version vendorHash;
    pname = "pomerium-get-envoy";

    subPackages = [
      "pkg/envoy/get-envoy"
    ];
    # get-envoy's envoy version is pinned via pkg/envoy/envoyversion, which
    # relies on a specific version of github.com/pomerium/envoy-custom as a Go module,
    # and then fetches that version's release binaries from GHCR.
  };
in
buildGoModule (finalAttrs: {
  inherit src version vendorHash;
  pname = "pomerium";

  preBuild = ''
    # Insert embedded envoy.
    cp -r ${finalAttrs.envoyBinaries}/* pkg/envoy/files

    # put the built UI files where they will be picked up as part of binary build
    cp -r ${finalAttrs.ui}/* ui/dist
  '';

  installPhase = ''
    install -Dm0755 $GOPATH/bin/pomerium $out/bin/pomerium
  '';

  envoyBinaries =
    runCommand "pomerium-envoy-binaries"
      {
        nativeBuildInputs = [ getEnvoy ];
        outputHash = "sha256-i2DuOx+fSCwTKavf6zvuRd1AKbk4igrzy2AXinDkyrI=";
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";

        meta = {
          homepage = "https://github.com/pomerium/envoy-custom";
          sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        };
      }
      ''
        mkdir $out
        cd $out
        get-envoy
        chmod +x envoy-darwin-amd64 envoy-darwin-arm64 envoy-linux-amd64 envoy-linux-arm64
      '';

  ldflags =
    let
      # Set a variety of useful meta variables for stamping the build with.
      setVars = {
        "github.com/pomerium/pomerium/internal/version" = {
          BuildMeta = "nixpkgs";
          ProjectName = "pomerium";
          ProjectURL = "github.com/pomerium/pomerium";
          Version = "v${finalAttrs.version}";
        };
      };
      concatStringsSpace = list: concatStringsSep " " list;
      mapAttrsToFlatList = fn: list: concatMap id (mapAttrsToList fn list);
      varFlags = concatStringsSpace (
        mapAttrsToFlatList (
          package: packageVars:
          mapAttrsToList (variable: value: "-X ${package}.${variable}=${value}") packageVars
        ) setVars
      );
    in
    [
      "${varFlags}"
    ];

  subPackages = [
    "cmd/pomerium"
  ];

  ui = buildNpmPackage {
    inherit (finalAttrs) version;
    pname = "pomerium-ui";
    src = "${finalAttrs.src}/ui";
    npmDepsHash = "sha256-2fzINp3LBPHPJlzJnUggPWUZHrjuX9TYPD2XvioonSw=";

    installPhase = ''
      runHook preInstall
      cp -R dist $out
      runHook postInstall
    '';
  };

  passthru = {
    tests = {
      inherit (nixosTests) pomerium;
      inherit pomerium-cli;
    };

    updateScript = ./updater.sh;
  };

  meta = {
    description = "Authenticating reverse proxy";
    homepage = "https://pomerium.io";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      lukegb
      devusb
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "pomerium";
  };
})
