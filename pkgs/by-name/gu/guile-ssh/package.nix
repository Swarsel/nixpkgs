{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  guile,
  libssh,
  pkg-config,
  texinfo,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guile-ssh";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "artyom-poptsov";
    repo = "guile-ssh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-q7P/ehafnDtJhHOAWbswOfztkKHVtEw8OgcXKufVAX4=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-J+TDgdjihKoEjhbeH+BzqrHhjpVlGdscRj3L/GAFgKg=";
      url = "https://github.com/artyom-poptsov/guile-ssh/pull/31/commits/38636c978f257d5228cd065837becabf5da16854.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    guile
    pkg-config
    texinfo
    which
  ];

  buildInputs = [
    guile
  ];

  propagatedBuildInputs = [
    libssh
  ];

  # FAIL: server-client.scm
  doCheck = !stdenv.hostPlatform.isDarwin;

  postInstall = ''
    mv $out/bin/*.scm $out/share/guile-ssh
    rmdir $out/bin
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Bindings to Libssh for GNU Guile";
    homepage = "https://github.com/artyom-poptsov/guile-ssh";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      ethancedwards8
    ];

    platforms = guile.meta.platforms;
  };
})
