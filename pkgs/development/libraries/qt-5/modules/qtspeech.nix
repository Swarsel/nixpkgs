{
  lib,
  stdenv,
  pkg-config,
  qtModule,
  speechd-minimal,
}:

qtModule {
  pname = "qtspeech";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ speechd-minimal ];
}
