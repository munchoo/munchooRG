from configparser import ConfigParser

# Initialize the Parser.
config = ConfigParser()

# Add the Section.
config.add_section("graph_api")

# Set the Values.
config.set("graph_api", "client_id", "312435a5-4dd6-40f8-a606-49bbb30c254d")
config.set("graph_api", "client_secret", "6SH7Q~-bKmoBmiVopd-sRv6cjKwQd-HB9g2GL")
config.set("graph_api", "redirect_uri", "https://localhost/graph_login")

# Write the file.
with open(file="./ms-graph-python-client-master/samples/configs/config.ini", mode="w+", encoding="utf-8") as f:
    config.write(f)
