{
  lib,
  stdenv,
  fetchFromGitHub,
  bash-completion,
  docbook_xsl,
  libcap,
  libselinux,
  libxslt,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bubblewrap";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "bubblewrap";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MUjJMhJ8Q9sYQyGqA7zfMutYjMSZNmEHXs2H3WN4mbE=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    substituteInPlace tests/libtest.sh \
      --replace "/var/tmp" "$TMPDIR"
  '';

  nativeBuildInputs = [
    docbook_xsl
    libxslt
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    bash-completion
    libcap
    libselinux
  ];

  # incompatible with Nix sandbox
  doCheck = false;

  meta = {
    description = "Unprivileged sandboxing tool";
    homepage = "https://github.com/containers/bubblewrap";
    changelog = "https://github.com/containers/bubblewrap/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.linux;
    mainProgram = "bwrap";
  };
})
