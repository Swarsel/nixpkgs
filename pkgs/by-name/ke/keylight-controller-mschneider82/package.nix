{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libGL,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxxf86vm,
  nssmdns,
  pkg-config,
  xinput,
}:

buildGoModule rec {
  pname = "keylight-controller-mschneider82";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "mschneider82";
    repo = "keylight-control";
    rev = "v${version}";
    hash = "sha256-xC/JRM8vyqAsxPpf37P3pZv6i73s+CLQt6Sh4nMxwzM=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libGL
    nssmdns
    libx11
    libx11.dev
    libxcursor
    libxext
    libxi
    libxinerama
    libxrandr
    libxxf86vm
    xinput
  ];

  vendorHash = "sha256-nFttVJbEAAGsrAglMphuw0wJ2Kf8sWB4HrpVqfHO76o=";

  meta = {
    description = "Desktop application to control Elgato Keylights";

    longDescription = ''
      Requires having:
      * Elgato's Keylight paired to local wifi network.
      * Service avahi with nssmdns4 enabled.
    '';

    homepage = "https://github.com/mschneider82/keylight-control";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "keylight-control";
  };
}

# Note: Application errors on first executions but works on re-runs.

# Troubleshooting
# 1. Keylight lists at: `avahi-browse --all --resolve --ignore-local`
# 2. Ping Keylight's IP
# 3. Resolve Keylight's hostname: `getent hosts elgato-key-light-XXXX.local`
