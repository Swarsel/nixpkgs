{
  lib,
  stdenv,
  buildGoModule,
  fetchFromSourcehut,
  mpv-unwrapped,
  pkg-config,
}:
buildGoModule (finalAttrs: {
  pname = "ostui";
  version = "1.3.4";

  src = fetchFromSourcehut {
    owner = "~ser";
    repo = "ostui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+8YZiFV86SuTYQT+FTMo55dQy/W35hD+mcJp8MUz17s=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ pkg-config ];
  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ mpv-unwrapped ];
  vendorHash = "sha256-cCyOG6nqlw2DPbA1dCuki5cpDy9LmZV/3YGyB3nCreI=";
  env.CGO_ENABLED = if stdenv.hostPlatform.isLinux then "0" else "1";

  postConfigure = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace vendor/github.com/gen2brain/go-mpv/purego_linux.go \
      --replace-warn '"libmpv.so"' '"${lib.getLib mpv-unwrapped}/lib/libmpv.so"' \
      --replace-warn '"libmpv.so.2"' '"${lib.getLib mpv-unwrapped}/lib/libmpv.so.2"'
  '';

  doCheck = !stdenv.hostPlatform.isDarwin;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Terminal client for *sonic music servers, inspired by ncmpcpp and musickube";
    homepage = "https://git.sr.ht/~ser/ostui";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ m0streng0 ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "ostui";
  };
})
