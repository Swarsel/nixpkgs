{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  imlib2Full,
  jpegexiforient,
  libexif,
  libjpeg,
  libpng,
  libx11,
  libxinerama,
  libxt,
  makeWrapper,
  perl,
  enableAutoreload ? !stdenv.hostPlatform.isDarwin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "feh";
  version = "3.12.2";

  src = fetchFromGitHub {
    owner = "derf";
    repo = "feh";
    rev = finalAttrs.version;
    hash = "sha256-YAVj4ZD4WchMalIUyqnw4sZTTTnLouv9VDwqK6q3SAE=";
  };

  outputs = [
    "out"
    "man"
    "doc"
  ];

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    libxt
    libx11
    libxinerama
    imlib2Full
    libjpeg
    libpng
    curl
    libexif
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "VERSION=${finalAttrs.version}"
    "exif=1"
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin "verscmp=0"
  ++ lib.optional enableAutoreload "inotify=1";

  doCheck = true;
  nativeCheckInputs = lib.singleton (perl.withPackages (p: [ p.TestCommand ]));

  postInstall = ''
    wrapProgram "$out/bin/feh" --prefix PATH : "${
      lib.makeBinPath [
        libjpeg
        jpegexiforient
      ]
    }" \
                               --add-flags '--theme=feh'
  '';

  installTargets = [ "install" ];

  meta = {
    description = "Light-weight image viewer";
    homepage = "https://feh.finalrewind.org/";
    # released under a variant of the MIT license
    # https://spdx.org/licenses/MIT-feh.html
    license = lib.licenses.mit-feh;

    maintainers = with lib.maintainers; [
      gepbird
    ];

    platforms = lib.platforms.unix;
    mainProgram = "feh";
  };
})
