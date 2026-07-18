{
  lib,
  stdenv,
  curl,
}:
lib.fetchers.withNormalizedHash
  {
    hashTypes = [
      "sha1"
      "sha256"
      "sha512"
    ];
  }
  (
    {
      ipfs,
      outputHash,
      outputHashAlgo,
      curlOpts ? "",
      meta ? { },
      port ? "8080",
      postFetch ? "",
      preferLocalBuild ? true,
      url ? "",
    }:
    stdenv.mkDerivation {
      # New-style output content requirements.
      inherit outputHash outputHashAlgo;

      inherit
        curlOpts
        postFetch
        ipfs
        url
        port
        meta
        ;

      # Doing the download on a remote machine just duplicates network
      # traffic, so don't do that.
      inherit preferLocalBuild;
      nativeBuildInputs = [ curl ];
      builder = ./builder.sh;
      name = ipfs;
      outputHashMode = "recursive";
    }
  )
