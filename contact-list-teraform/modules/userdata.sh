    #!/bin/bash
    yum update -y
    yum install python3 -y
    pip3 install flask
    pip3 install flask_mysql
    yum install git -y
    sleep 10
    git clone https://github.com/BenguCambay/Terraform-Project.git
    sleep 10
    cd /home/ec2-user/Terraform-Project
    python3 /home/ec2-user/Terraform-Project/contact-list-app.py
    
