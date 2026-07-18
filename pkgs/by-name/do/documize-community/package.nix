{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go-bindata,
  go-bindata-assetfs,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "documize-community";
  version = "3.9.0";

  src = fetchFromGitHub {
    owner = "documize";
    repo = "community";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Kv4BsFB08rkGRkePFIkjjuhK1TnLPS4m+PUlgKG5cTQ=";
  };

  nativeBuildInputs = [
    go-bindata
    go-bindata-assetfs
  ];

  vendorHash = null;
  # This is really weird, but they've managed to screw up
  # their folder structure enough, you can only build by
  # literally cding into this folder.
  preBuild = "cd edition";
  doCheck = false;

  postInstall = ''
    mv $out/bin/edition $out/bin/documize
  '';

  subPackages = [ "." ];
  passthru.tests = { inherit (nixosTests) documize; };

  meta = {
    description = "Open source Confluence alternative for internal & external docs built with Golang + EmberJS";
    homepage = "https://www.documize.com/";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    mainProgram = "documize";
  };
})
