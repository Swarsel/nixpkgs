{
  lib,
  newScope,
  python3,
}:
# Take packages from self first, then python.pkgs (and secondarily pkgs)
lib.makeScope (self: newScope (self.python.pkgs // self)) (self: {
  buildbot = self.callPackage ./master.nix { };

  buildbot-full = self.buildbot.withPlugins (
    with self.buildbot-plugins;
    [
      www
      console-view
      waterfall-view
      grid-view
      wsgi-dashboards
      badges
    ]
  );

  buildbot-pkg = self.callPackage ./pkg.nix { };
  buildbot-plugins = lib.recurseIntoAttrs (self.callPackage ./plugins.nix { });
  buildbot-ui = self.buildbot.withPlugins (with self.buildbot-plugins; [ www ]);
  buildbot-worker = self.callPackage ./worker.nix { };
  python = python3;
})
