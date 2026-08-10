#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
sudo cat > /usr/share/nginx/html/index.html << 'WEBSITE'
<html>
<head>
    <title>Taco Team Server - ${environment}</title>
    <style>
        html, body {
            height: 100%;
            margin: 0;
        }
        body {
            background-color: #0ba7ce;
            display: flex;
            justify-content: center;
            align-items: center;
        }
    </style>
</head>
<body>
    <div>
        <p style="text-align: center;">
            <span style="color:#FFFFFF;">
                <span style="font-size:100px;">AWS Networking journey</span>
            </span>
        </p>
        <p style="text-align: center;">
            <span style="color:#FFFFFF;">
                <span style="font-size:100px;">Welcome to the ${environment} environment!</span>
            </span>
            <span style="color:#FFFFFF;">
                <span style="font-size:100px;">This is ${instance_name} with IP ${instance_ip}!</span>
            </span>
        </p>

    </div>
</body>
</html>
WEBSITE