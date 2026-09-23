sudo apt update && sudo apt install -y curl gnupg ca-certificates
curl -fsSL https://mongodb.com | \
  sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg
echo "deb [signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.0 main" | \
  sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
curl -fsSL https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc | sudo gpg --dearmor --yes -o /usr/share/keyrings/pritunl.gpg
echo "deb [signed-by=/usr/share/keyrings/pritunl.gpg] https://repo.pritunl.com/stable/apt trixie main" | sudo tee /etc/apt/sources.list.d/pritunl.list
sudo apt update
sudo apt install -y mongodb-org pritunl
sudo systemctl start mongod pritunl
sudo systemctl enable mongod pritunl
