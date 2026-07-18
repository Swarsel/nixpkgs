{
  lib,
  fetchFromGitLab,
  capnproto,
  cmake,
  gitUpdater,
  protobuf,
  rustPlatform,
  testers,
  veilid,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "veilid";
  version = "0.5.5";

  src = fetchFromGitLab {
    owner = "veilid";
    repo = "veilid";
    rev = "v${finalAttrs.version}";
    hash = "sha256-14jRIs2iE5JH1ZmC/1DGcg6cejsnmhUTkquXNmOEuQA=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  nativeBuildInputs = [
    capnproto
    cmake
    protobuf
  ];

  cargoHash = "sha256-xuIw/RRKydanStS7dw1jK96bgEH0U5TDbayaBZq/OCg=";
  env.RUSTFLAGS = "--cfg tokio_unstable";
  doCheck = false;

  postInstall = ''
    moveToOutput "lib" "$lib"
  '';

  cargoBuildFlags = [
    "--workspace"
  ];

  passthru = {
    tests = {
      veilid-version = testers.testVersion {
        package = veilid;
      };
    };

    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Open-source, peer-to-peer, mobile-first, networked application framework";
    homepage = "https://veilid.com";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      bbigras
      qbit
    ];

    mainProgram = "veilid-server";
  };
})
