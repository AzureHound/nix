{
  description = "Init flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, ... }: {
    nixosConfigurations.Orion = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko

        ./disko.nix
        ./hardware.nix

        ({ pkgs, ... }: {
          boot.loader = {
            efi.canTouchEfiVariables = true;
            systemd-boot = {
              enable = true;
              consoleMode = "max";
            };
          };

          networking = {
            hostName = "Orion";
            networkmanager.enable = true;
          };

          nix = {
            settings.experimental-features = [
              "nix-command"
              "flakes"
            ];

            channel.enable = false;
          };

          services.openssh.enable = true;

          environment.systemPackages = with pkgs; [
            git
            vim
          ];

          users.users.eden = {
            isNormalUser = true;
            extraGroups = [
              "wheel"
              "networkmanager"
            ];
            initialPassword = "passwd";
          };

          system.stateVersion = "26.05";
        })
      ];
    };
  };
}
