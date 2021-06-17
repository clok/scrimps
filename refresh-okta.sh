#!/bin/bash

reset="\e[0m"
green="\e[32m"

success() {
  printf "${green}✔ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}

echo "#!/bin/bash" > /tmp/aws-okta-env
aws-okta env developer >> /tmp/aws-okta-env

success "aws-okta env exported to shell"
