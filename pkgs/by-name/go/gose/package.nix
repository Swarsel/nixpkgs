{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromCodeberg,
  nix-update-script,
  versionCheckHook,
}:
let
  version = "0.11.4";

  src = fetchFromCodeberg {
    owner = "stv0g";
    repo = "gose";
    tag = "v${version}";
    hash = "sha256-T6PD6MI1IOAgtPOJuPSZp4te9BokKfj+TZHLRqt2FCo=";
  };

  frontend = buildNpmPackage {
    inherit version;
    pname = "gose-frontend";
    src = "${src}/frontend";
    npmDepsHash = "sha256-p24s2SgCL8E9vUoZEyWSrd15IdkprneAXS7dwb7UbyA=";

    installPhase = ''
      runHook preInstall
      find ./dist
      mkdir $out
      cp -r dist/* $out/
      runHook postInstall
    '';
  };
in
buildGoModule {
  inherit version;
  inherit src;
  pname = "gose";
  vendorHash = "sha256-PTu4OzVjGVExuNDsK01p3/gAwNhDZbPewhI476m5i/M=";
  env.CGO_ENABLED = 0;
  # Skipping test which relies on internet services.
  checkFlags = "-skip TestShortener";

  postInstall = ''
    mv $out/bin/cmd $out/bin/gose
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
    "-X main.builtBy=Nix"
  ];

  prePatch = ''
    cp -r ${frontend} frontend/dist
  '';

  tags = [ "embed" ];
  versionCheckProgramArg = "-version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern and scalable file-uploader focusing on scalability and simplicity";
    homepage = "https://github.com/stv0g/gose";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ stv0g ];
    mainProgram = "gose";
  };
}
