{
  lib,
  fetchFromGitHub,
  bash,
  dbus,
  libxcb,
  nano,
  pkg-config,
  procps,
  rustPlatform,
  watch,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tattoy";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "tattoy-org";
    repo = "tattoy";
    tag = "tattoy-v${finalAttrs.version}";
    hash = "sha256-44rXygZVbwwC/jOB69iHydsjYr/WeVU4Eky3BPqJzyc=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    libxcb
  ];

  cargoHash = "sha256-DJyml8J9XXKD2t1dQz+OrVDFcq6PLMoDlhiLo86D3CM=";

  nativeCheckInputs = [
    bash
    nano
    procps
    watch
  ];

  checkFlags =
    lib.concatMap
      (t: [
        "--skip"
        "${t}"
      ])
      [
        # e2e tests currently fail
        # see https://github.com/tattoy-org/tattoy/pull/104/files for discussion
        # re-enable after PR merged
        "e2e"
        "gpu"
      ];

  useNextest = true;

  meta = {
    description = "Text-based compositor for modern terminals";
    homepage = "https://github.com/tattoy-org/tattoy";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      DieracDelta
    ];

    platforms = lib.platforms.unix;
    mainProgram = "tattoy";
  };
})
