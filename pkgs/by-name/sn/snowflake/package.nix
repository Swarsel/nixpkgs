{
  lib,
  fetchFromGitLab,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "snowflake";
  version = "2.14.1";

  src = fetchFromGitLab {
    owner = "anti-censorship/pluggable-transports";
    repo = "snowflake";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-MvV1kP+Xm3a4Q8+YZLwC9vpVK54ltb73cRkJhReSA2U=";
    domain = "gitlab.torproject.org";
    group = "tpo";
  };

  vendorHash = "sha256-onxJDRURyQIA+t4PbuIk14VkVUFnuALTteF9nfMZuBY=";

  meta = {
    description = "System to defeat internet censorship";
    homepage = "https://snowflake.torproject.org/";
    changelog = "https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake/-/raw/v${finalAttrs.version}/ChangeLog";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      bbjubjub
      yayayayaka
    ];
  };
})
