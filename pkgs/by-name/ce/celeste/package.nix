{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  dbus,
  gdk-pixbuf,
  glib,
  graphene,
  gtk4,
  just,
  libadwaita,
  librclone,
  pango,
  pkg-config,
  rclone,
  rustPlatform,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "celeste";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "hwittenborn";
    repo = "celeste";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Yj2PvAlAkwLaSE27KnzEmiRAD5K/YVGbF4+N3uhDVT8=";
  };

  # rust 2024 requires that you put an unsafe block around std::env::set_var
  patches = [ ./missing-unsafe-block.patch ];

  postPatch = ''
    pushd $cargoDepsCopy/*/librclone-sys-*
    oldHash=$(sha256sum build.rs | cut -d " " -f 1)
    patch -p2 < ${./librclone-path.patch}
    substituteInPlace build.rs \
      --subst-var-by librclone ${librclone}
    substituteInPlace .cargo-checksum.json \
      --replace $oldHash $(sha256sum build.rs | cut -d " " -f 1)
    popd

    substituteInPlace justfile \
      --replace "{{ env_var('DESTDIR') }}/usr" "${placeholder "out"}"
    # buildRustPackage takes care of installing the binary
    sed -i "#/bin/celeste#d" justfile

    # fix: as of rust 1.85, it is required that you specify edition 2024 for let chains
    substituteInPlace Cargo.toml \
      --replace-warn 'edition = "2021"' 'edition = "2024"'
  '';

  nativeBuildInputs = [
    just
    pkg-config
    rustPlatform.bindgenHook
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    dbus
    gdk-pixbuf
    glib
    graphene
    gtk4
    libadwaita
    librclone
    pango
  ];

  cargoHash = "sha256-OBGDnhpVLOPdYhofWfeaueklt7KBkLhM02JNvuvUQ2Q=";

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.hostPlatform.isDarwin [
      "-Wno-error=incompatible-function-pointer-types"
    ]
  );

  env.RUSTC_BOOTSTRAP = 1;

  postInstall = ''
    just install
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ rclone ]}"
    )
  '';

  meta = {
    description = "GUI file synchronization client that can sync with any cloud provider";
    homepage = "https://github.com/hwittenborn/celeste";
    changelog = "https://github.com/hwittenborn/celeste/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "celeste";
  };
})
