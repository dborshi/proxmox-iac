# Install tools
brew install terraform talhelper sops age go-task

mkdir -p ~/.config/sops/age
chmod 700 ~/.config/sops/age
chmod 600 ~/.config/sops/age/keys.txt

# Generate an age key for sops encryption
age-keygen -o ~/.config/sops/age/keys.txt

Set Display to VGA
Set manual IP in Console