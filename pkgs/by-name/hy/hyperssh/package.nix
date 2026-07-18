{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildNpmPackage,
  patchelfUnstable,
}:

buildNpmPackage {
  pname = "hyperssh";
  version = "5.0.3";

  src = fetchFromGitHub {
    owner = "holepunchto";
    repo = "hyperssh";
    rev = "v5.0.3";
    hash = "sha256-vjPSNcQRsqu0ee0hownEE9y8dFf9dqaL7alGRc9WjcI=";
  };

  patches = [
    # TODO: remove after this is merged: https://github.com/holepunchto/hyperssh/pull/16
    (fetchurl {
      hash = "sha256-fUjgHHbZHgqokNg2fVVZCjoDA3LqSJiFzBwgA8Tt1m4=";
      url = "https://github.com/holepunchto/hyperssh/commit/ad1d0e06a133e71c9df9f59dd5f805c49f46ec70.patch";
    })
  ];

  nativeBuildInputs = [
    patchelfUnstable # --clear-execstack is only available on 0.18
  ];

  npmDepsHash = "sha256-nT++cvYbY+zsebIaMZ0hUhK9pAX17GTbQyuixdCjojM=";

  postInstall = ''
    # glibc 2.41+ refuses to make the stack executable if it isn't executable,
    # but a library loaded via `dlopen()` mandates it.
    # According to https://github.com/holepunchto/sodium-native/issues/214
    # this isn't necessary in this case.
    while IFS= read -r -d ''' file; do
      # Skip PEs with the same name
      if patchelf --print-rpath "$file" &>/dev/null; then
        patchelf "$file" --clear-execstack
      fi
    done < <(find $out/lib/node_modules -name 'sodium-native.node' -print0)
  '';

  dontNpmBuild = true;
  makeCacheWritable = true;

  meta = {
    description = "Run SSH over hyperswarm";
    homepage = "https://github.com/holepunchto/hyperssh";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ davhau ];
    platforms = lib.platforms.all;
    mainProgram = "hyperssh";
  };
}
