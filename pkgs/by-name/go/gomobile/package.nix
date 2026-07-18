{
  lib,
  stdenv,
  androidenv,
  buildGoModule,
  fetchgit,
  makeWrapper,
  xcodeenv,
  zlib,
  androidPkgs ? (
    androidenv.composeAndroidPackages {
      includeNDK = true;
    }
  ),
  withAndroidPkgs ? true,
  xcodeWrapper ? xcodeenv.composeXcodeWrapper xcodeWrapperArgs,
  xcodeWrapperArgs ? { },
}:
buildGoModule {
  pname = "gomobile";
  version = "0-unstable-2024-12-13";

  src = fetchgit {
    url = "https://go.googlesource.com/mobile";
    rev = "a87c1cf6cf463f0d4476cfe0fcf67c2953d76e7c";
    hash = "sha256-7j4rdmCZMC8tn4vAsC9x/mMNkom/+Tl7uAY+5gkSvfY=";
    name = "gomobile";
  };

  # Prevent a non-deterministic temporary directory from polluting the resulting object files
  postPatch = ''
    substituteInPlace cmd/gomobile/env.go --replace \
      'tmpdir, err = ioutil.TempDir("", "gomobile-work-")' \
      'tmpdir = filepath.Join(os.Getenv("NIX_BUILD_TOP"), "gomobile-work")'
    substituteInPlace cmd/gomobile/init.go --replace \
      'tmpdir, err = ioutil.TempDir(gomobilepath, "work-")' \
      'tmpdir = filepath.Join(os.Getenv("NIX_BUILD_TOP"), "work")'
  '';

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ xcodeWrapper ];
  vendorHash = "sha256-6ycxEDEE0/i6Lxo0gb8wq3U2U7Q49AJj+PdzSl57wwI=";
  # Fails with: go: cannot find GOROOT directory
  doCheck = false;

  # Necessary for GOPATH when using gomobile.
  postInstall = ''
    mkdir -p $out/src/golang.org/x
    ln -s $src $out/src/golang.org/x/mobile
  '';

  postFixup = ''
    for prog in gomobile gobind; do
      wrapProgram $out/bin/$prog \
        --suffix GOPATH : $out \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ zlib ]}" \
        ${lib.optionalString withAndroidPkgs ''
          --prefix PATH : "${androidPkgs.androidsdk}/bin" \
          --set-default ANDROID_HOME "${androidPkgs.androidsdk}/libexec/android-sdk"
        ''}
    done
  '';

  subPackages = [
    "bind"
    "cmd/gobind"
    "cmd/gomobile"
  ];

  meta = {
    description = "Tool for building and running mobile apps written in Go";
    homepage = "https://pkg.go.dev/golang.org/x/mobile/cmd/gomobile";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ jakubgs ];
  };
}
