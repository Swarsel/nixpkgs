{
  lib,
  stdenv,
  fetchFromGitLab,
  doxygen,
  # runtime deps
  glib,
  # GI build deps
  gobject-introspection,
  graphviz,
  lua5_4,
  # base build deps
  meson,
  ninja,
  nix-update-script,
  pipewire,
  pkg-config,
  # docs build deps
  python3,
  systemd,
  # options
  enableDocs ? true,
  enableGI ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wireplumber";
  version = "0.5.15";

  src = fetchFromGitLab {
    owner = "pipewire";
    repo = "wireplumber";
    tag = finalAttrs.version;
    hash = "sha256-28JrX8V23VpTe6GPI6g/JlN7412yJLMcwEre2Jv77qg=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optional enableDocs "doc";

  strictDeps = true;

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ]
  ++ lib.optionals enableDocs [
    graphviz
  ]
  ++ lib.optionals enableGI [
    gobject-introspection
  ]
  ++ lib.optionals (enableDocs || enableGI) [
    doxygen
    (python3.pythonOnBuildForHost.withPackages (
      ps:
      with ps;
      lib.optionals enableDocs [
        sphinx
        sphinx-rtd-theme
        breathe
      ]
      ++ lib.optionals enableGI [ lxml ]
    ))
  ];

  buildInputs = [
    glib
    systemd
    lua5_4
    pipewire
  ];

  mesonFlags = [
    (lib.mesonBool "system-lua" true)
    (lib.mesonEnable "elogind" false)
    (lib.mesonEnable "doc" enableDocs)
    (lib.mesonEnable "introspection" enableGI)
    (lib.mesonBool "systemd-system-service" true)
    (lib.mesonOption "systemd-system-unit-dir" "${placeholder "out"}/lib/systemd/system")
    (lib.mesonOption "sysconfdir" "/etc")
  ];

  __structuredAttrs = true;
  separateDebugInfo = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modular session / policy manager for PipeWire";
    homepage = "https://pipewire.org";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      k900
      qweered
    ];

    platforms = lib.platforms.linux;
  };
})
