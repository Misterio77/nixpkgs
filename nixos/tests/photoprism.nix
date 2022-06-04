import ./make-test-python.nix ({ pkgs, ... }: {
  name = "photoprism";

  nodes.machine = { ... }: {
    environment.systemPackages = [ pkgs.curl ];
    services.photoprism = {
      enable = true;
      originalsDir = "/tmp";
    };
  };

  testScript = ''
    machine.wait_for_unit("photoprism")
    machine.wait_for_open_port(2342)
    machine.succeed("curl -fSs http://localhost:2342/auth/login")
  '';
})
