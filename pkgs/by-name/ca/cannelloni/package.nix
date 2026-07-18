{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  lksctp-tools,
  nix-update-script,
  versionCheckHook,
  sctpSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cannelloni";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "mguentner";
    repo = "cannelloni";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lHZmsgtIL7edODXV8lWfVwMhnS40n9wD8iVyAzJycbA=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = lib.optionals sctpSupport [ lksctp-tools ];

  cmakeFlags = [
    "-DSCTP_SUPPORT=${lib.boolToString sctpSupport}"
  ];

  doInstallCheck = true;

  nativeInstallInputs = [
    versionCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "SocketCAN over Ethernet tunnel";
    homepage = "https://github.com/mguentner/cannelloni";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.samw ];
    platforms = lib.platforms.linux;
    mainProgram = "cannelloni";
  };
})
