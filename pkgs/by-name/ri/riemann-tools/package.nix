{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "riemann-tools";

  exes = [
    "riemann-apache-status"
    "riemann-bench"
    "riemann-cloudant"
    "riemann-consul"
    "riemann-dir-files-count"
    "riemann-dir-space"
    "riemann-diskstats"
    "riemann-fd"
    "riemann-freeswitch"
    "riemann-haproxy"
    "riemann-health"
    "riemann-kvminstance"
    "riemann-memcached"
    "riemann-net"
    "riemann-nginx-status"
    "riemann-ntp"
    "riemann-portcheck"
    "riemann-proc"
    "riemann-varnish"
    "riemann-zookeeper"
  ];

  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "riemann-tools";

  meta = {
    description = "Tools to submit data to Riemann";
    homepage = "https://riemann.io";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];
  };
}
