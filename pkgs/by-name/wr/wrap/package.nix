{
  lib,
  fetchFromGitHub,
  buildGoModule,
  courier-prime,
  fetchpatch,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "wrap";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "Wraparound";
    repo = "wrap";
    rev = "v${finalAttrs.version}";
    hash = "sha256-58wsH/e3X72S7tJUObazyvvkI8+B7DLPTBmQO9A+jmk=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-hcUsRyv6XVN+GyMN7LXzXPsp8jYUKTJPaK+e5p4CO7U=";
      name = "courier-prime-variants.patch";
      url = "https://github.com/Wraparound/wrap/commit/b72c280b6eddba9ec7b3507c1f143eb28a85c9c1.patch";
    })
    # Fix build on Go 1.17+
    (fetchpatch {
      hash = "sha256-eIKvA91olfbNJhOhIUu3GOL/rbgX3m6unmU8nRdKbtc=";
      url = "https://github.com/Wraparound/wrap/commit/a222c18a7e0810486741684781ff6158a359a8ba.patch";
    })
  ];

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-vg61Vypd+mSF9FyLFVpnS5UCTJDoobkDE1Cneg8O0RM=";

  postInstall = ''
    wrapProgram $out/bin/wrap --prefix XDG_DATA_DIRS : ${courier-prime}/share/
  '';

  meta = {
    description = "Fountain export tool with some extras";
    homepage = "https://github.com/Wraparound/wrap";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.austinbutler ];
  };
})
