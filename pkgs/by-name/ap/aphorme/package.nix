{
  lib,
  stdenv,
  fetchFromGitHub,
  aphorme,
  autoPatchelfHook,
  libGL,
  libxkbcommon,
  rustPlatform,
  testers,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aphorme";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Iaphetes";
    repo = "aphorme_launcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eSJlWInGMFnn+16um7j8Dp92LYdNsfAdLJQSQIDAlaA=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];
  cargoHash = "sha256-CRDVIY5HVMFme+fOf9tdoT+VVy5z2+s5opw/KH25YOw=";
  # No tests exist
  doCheck = false;

  runtimeDependencies = [
    wayland
    libGL
    libxkbcommon
  ];

  passthru.tests.version = testers.testVersion {
    version = "aphorme ${finalAttrs.version}";
    command = "aphorme --version";
    package = aphorme;
  };

  meta = {
    description = "Program launcher for window managers, written in Rust";
    homepage = "https://github.com/Iaphetes/aphorme_launcher";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ anytimetraveler ];
    platforms = lib.platforms.linux;
    mainProgram = "aphorme";
  };
})
