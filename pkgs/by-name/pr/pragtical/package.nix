{
  lib,
  stdenv,
  fetchFromGitHub,
  cacert,
  freetype,
  harfbuzz,
  libgit2,
  libkqueue,
  libuchardet,
  libzip,
  lua5_4,
  luajit,
  mbedtls_4,
  meson,
  ninja,
  pcre2,
  pkg-config,
  sdl3,
  sdl3-image,
  sdl3-net,
  xz,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pragtical";
  version = "3.11.2";

  src = fetchFromGitHub {
    owner = "pragtical";
    repo = "pragtical";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OkvtPH8XiF3nkZ66PnKm+++NWWDK1ypGmjiZYGOiIe8=";
    fetchSubmodules = true;

    # also fetch required git submodules
    postFetch = ''
      cd "$out"

      export NIX_SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

      substituteInPlace subprojects/ppm.wrap \
        --replace-fail 'revision = head' 'revision = ${finalAttrs.pluginManagerRev}'
      substituteInPlace subprojects/linenoise.wrap \
        --replace-fail 'revision = master' 'revision = ${finalAttrs.linenoiseRev}'

      ${lib.getExe meson} subprojects download \
        colors linenoise plugins ppm widget

      find subprojects -type d -name .git -prune -execdir rm -r {} +
    '';
  };

  strictDeps = true;

  nativeBuildInputs = [
    lua5_4 # needed for built-time lua bytecode generation
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    freetype
    harfbuzz
    libgit2
    libkqueue # optional
    libuchardet
    libzip
    lua5_4
    luajit
    mbedtls_4
    pcre2
    sdl3
    sdl3-image
    sdl3-net
    xz
    zlib
  ];

  mesonFlags = [
    (lib.mesonBool "use_system_lua" true)
  ];

  linenoiseRev = "e78e236c8d85c078fdd9fc4e1f08716058aa1a42";
  pluginManagerRev = "v1.5.2";

  meta = {
    description = "Practical and pragmatic code editor";
    homepage = "https://pragtical.dev";
    changelog = "https://github.com/pragtical/pragtical/blob/${finalAttrs.src.rev}/changelog.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      suhr
      tomasajt
    ];

    platforms = lib.platforms.linux;
    mainProgram = "pragtical";
  };
})
