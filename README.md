# Automate Deploying Retail Banking App to Elastic Beanstalk 

## Purpose
 
 In our last project we got an introduction to setting up a CI/CD pipeline for deploying an application to AWS Elastic Beanstalk. The problem was the CD part of our pipeline was still manual. This project aims to automate the deployment of code to AWS Elastic Beanstalk using Jenkins, eliminating the manual steps involved in the initial deployment process. Previously, the code was manually downloaded, zipped, and uploaded to Elastic Beanstalk. Now, the goal is for Jenkins to handle this automatically after building and testing.

 To achieve this, Jenkins requires:

* **AWS Credentials**: To access the AWS account for deployment.

* **API Communication**: The ability to communicate with AWS Elastic Beanstalk APIs.

* **Deployment Stage**: A new stage added to our jenkins file which contain Instructions on what commands to execute during the deployment stage after building and testing our application.

## Clone Repository


1. Create an empty repository on your GitHub account.
2. Clone that repository locally by running the following command:
   ```
    git clone https://github.com/tjwkura5/retail-banking-app-deployed-elastic-beanstalk-2.git
    ```
3. Clone the kura labs repository locally by running the following command:
    ```
    git clone https://github.com/kura-labs-org/C5-Deployment-Workload-2.git
    ```
4. Copy the files from the Kura Labs repository to your repository by running the following command: 

    ```
    cp -r /*/*/*/Kura_code/C5-Deployment-Workload-2/* /*/*/*/Kura_code/retail-banking-app-deployed-elastic-beanstalk-2
    ```
5. Push the code to your repository and delete the kura labs repo by running the following commands: 

    ```
    git push -u https://tjwkura5:{ACCESS_CODE}@github.com/tjwkura5/retail-banking-app-deployed-elastic-beanstalk-2.git main

    sudo rm -rf /*/*/*/Kura_code/C5-Deployment-Workload-1
    ```
## Create AWS Access Keys

**AWS access keys** are a set of security credentials that allow you to access Amazon Web Services (AWS) programmatically. There are two keys:

* **Access Key ID**: A unique identifier that is used to identify the key pair.

* **Secret Access Key**: A confidential string that is used to sign requests made to AWS APIs.

These keys are associated with an IAM user or role and in this project we are going to be using them to interact with aws services through the AWS Command Line Interface (CLI).

Sharing your AWS access keys is dangerous because someone with these keys can potentially access, modify, or delete resources in your AWS account, depending on the associated permissions.


1. Navigate to the AWS servce: IAM (search for this in the AWS console)

2. Click on "Users" on the left side navigation panel

3. Click on your User Name

4. Underneath the "Summary" section, click on the "Security credentials" tab

5. Scroll down to "Access keys" and click on "Create access key"

6. Select the appropriate "use case", and then click "Next" and then "Create access key"

7. View your access keys and store it somewhere safe becuase you will need them later. ACCESS KEYS CAN ONLY BE VIEWED ONCE!

## Create Bash Script to Test System Resources

Note: Why are exit codes important? Especially if running the script through a CICD Pipeline?



## Jenkins Server

**Setting Up the CI Server (Jenkins):**

1. **Create an EC2 Instance:** Follow the [AWS EC2 Quickstart Guide](https://github.com/kura-labs-org/AWS-EC2-Quick-Start-Guide/blob/main/AWS%20EC2%20Quick%20Start%20Guide.pdf)

2. Connect to the EC2 terminal and install Jenkins:

    ```
    $sudo apt update && sudo apt install fontconfig openjdk-17-jre software-properties-common && sudo add-apt-repository ppa:deadsnakes/ppa && sudo apt install python3.7 python3.7-venv
    $sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    $echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    $sudo apt-get update
    $sudo apt-get install jenkins
    $sudo systemctl start jenkins
    $sudo systemctl status jenkins
    ```

    If successful, the console output should look something like the following:

    ```
    ubuntu@ip-172-31-42-3:~$ sudo systemctl status jenkins

    ● jenkins.service - Jenkins Continuous Integration Server
    Loaded: loaded (/usr/lib/systemd/system/jenkins.service; enabled; preset: enabled)
    Active: active (running) since Sun 2024-07-28 00:25:53 UTC; 2min 25s ago
    Main PID: 4588 (java)
      Tasks: 39 (limit: 1130)
     Memory: 311.4M (peak: 330.8M)
        CPU: 46.541s
     CGroup: /system.slice/jenkins.service
             └─4588 /usr/bin/java -Djava.awt.headless=true -jar /usr/share/java/jenkins.war --webroot=/var/cache/jenkins/war --httpPort=8080

**Accessing the Jenkins Web Interface :**

1. Determine Jenkins's Public IP Address by checking your EC2 instance details in the AWS Management Console.
2. Open a web browser and navigate to `http://<your_ec2_instance_public_ip>:8080`.
3. Unlock Jenkins by finding the generated alphanumeric password in the Jenkins log file (`/var/lib/jenkins/secrets/initialAdminPassword`) and entering it on the setup screen.
4. Install recommended plugins for basic functionality.
5. Create an admin user by following on-screen instructions.

**Create a Multi Branch Pipeline and Connect Github to Jenkins :**

1. Click on “New Item” in the menu on the left of the page.

2. Enter a name for your pipeline.

3. Select “Multibranch Pipeline”.

4. Under “Branch Sources”, click “Add source” and select “GitHub”.

5. Click “+ Add” and select “Jenkins”.

6. Make sure “Kind” reads “Username and password”.

7. Under “Username”, enter your GitHub username.

8. Under “Password”, enter your GitHub personal access token. The instructions for creating a token can be found [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic)

9. Enter the repository HTTPS URL and click "Validate"

10. Make sure that the "Build Configuration" section says "Mode: by Jenkinsfile" and "Script Path: Jenkinsfile"

11. Click "Save"

Once you save the pipeline a build should start automatically and if it's successful it should look like the following:

![Successful Jenkins Build](documentation/Build_14.png)

![Pipeline Overview](documentation/pipeline_overview_14.png)

**Install AWS CLI on the Jenkins Server**

The **AWS Command Line Interface (AWS CLI)** is a tool that allows you to manage and interact with your AWS services directly from your command line or terminal. It provides a set of commands that you can use to perform various tasks, such as configuring and managing AWS resources, automating workflows, and executing scripts to perform repetitive tasks. In this phase of our project we will be installing the AWS CLI on our Jenkins server so that we can access our AWS account.

1. Navigate to the terminal of your EC2 Instance where you Installed Jenkins.

2. Install AWS CLI on the Jenkins Server with the following commands:

    ```
    $curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    $unzip awscliv2.zip
    $sudo ./aws/install
    $aws --version 
    ```

If AWS CLI was installed properly the version number will output to the terminal.

**Install AWS EB CLI on the Jenkins Server**

The **AWS Elastic Beanstalk Command Line Interface (EB CLI)** is a command-line tool specifically designed for interacting with AWS Elastic Beanstalk, a platform-as-a-service (PaaS) provided by AWS for deploying and managing applications.

1. Switch to the user "jenkins"

    a. create a password for the user "jenkins" by running:

    ```
    $sudo passwd jenkins
    ```
    b. switch to the jenkins user by running:

    ```
    sudo su - jenkins
    ```
2. Navigate to the pipeline directory within the jenkins "workspace"

    ```
    cd workspace/[name-of-multibranch-pipeline]
    ```

3. Activate the Python Virtual Environment

    ```
    source venv/bin/activate
    ```

    **NOTE:** A Python virtual environment is an isolated environment that allows you to manage and maintain separate dependencies for different Python projects on the same system. It essentially creates a self-contained directory that includes its own Python interpreter, libraries, and scripts, independent of the global Python environment installed on your machine. This is crucial for preventing conflicts between different projects that may have different dependencies and allowing for different projects to use different Python versions. Our python environment venv was created during the build stage of our jenkins pipeline. 


4. Configure AWS CLI with the folling command:

    ```
    $pip install awsebcli
    $eb --version
    ```
5. Configure AWS CLI with the folling command:

    ```
    $aws configure
    ```
    a. Enter your access key

   b. Enter your secret access key

   c. region: "us-east-1"

   d. output format" "json"

   e. check to see if AWS CLI has been configured by entering:

    ``` 
    $aws ec2 describe-instances 
    ```
6. Initialize AWS Elastic Beanstalk CLI by running the following command:

    ```
    eb init
    ```
  
   a. Set the default region to: us-east-1

   b. Enter an application name (or leave it as default)

   c. Select python3.7

   d. Select "no" for code commit

   e. Select "yes" for SSH and select a "KeyPair"

## Deply to Elastic Beanstalk

1. Add a "deploy" stage to the Jenkinsfile

    a. open your IDE and open the "jenkinsfile"

    b. add the following code block (modify the code with your environment name and remove the square brackets) AFTER the "Test" Stage:


    ```
    stage ('Deploy') {
            steps {
                sh '''#!/bin/bash
                source venv/bin/activate
                eb create retail-bank-env --single
                '''
            }
        }
    ```
2. Push these changes to the github repository

3. Navigate back to the Jenkins Console and build the pipeline again.


If the pipeline sucessfully completes, navigate to AWS Elastic Beanstalk in the AWS Console and check for the environment that is created. The application should be running at the domain created by Elastic Beanstalk.

![Successful Jenkins Build Two](documentation/Build_16_Final.png)

![Pipeline Overview Two](documentation/Build_16.png)

![Running App](documentation/running_app.png)

![Running App Login](documentation/running_app_two.png)

## Issues/Troubleshooting

## Optimization

How is using a deploy stage in the CICD pipeline able to increase efficiency of the buisiness? What issues, if any, can you think of that might come with automating source code to a production environment? How would you address/resolve this?

## Conclusion 
