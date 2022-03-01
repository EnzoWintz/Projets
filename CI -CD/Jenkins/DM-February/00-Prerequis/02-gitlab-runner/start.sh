#!/bin/bash
#Installation de gitlab-runner
sudo curl -L --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64" 
chmod +x /usr/local/bin/gitlab-runner && sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash && sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner 
sudo gitlab-runner start

