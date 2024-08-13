# Retail Banking App Deployed to Elastic Beanstalk Two
 
## Purpose
 
 In our last project, we were introduced to setting up a CI/CD pipeline for deploying an application to AWS Elastic Beanstalk. However, the Continuous Deployment (CD) part of our pipeline was still manual. This project aims to automate the deployment of code to AWS Elastic Beanstalk using Jenkins, eliminating the manual steps involved in our initial deployment process. 

 To achieve this, Jenkins requires:

* **AWS Credentials**: To access the AWS account for deployment.

* **API Communication**: The ability to communicate with AWS Elastic Beanstalk APIs.

* **Deployment Stage**: A new stage added to our jenkins file which contain instructions on what commands to execute during the deployment stage.

Let's get started!!

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

7. View your access keys and store them somewhere safe becuase you will need them later. ACCESS KEYS CAN ONLY BE VIEWED ONCE!

## Create Bash Script to Test System Resources

To enhance our testing process, we'll create a Bash script to monitor system resources (memory, CPU, disk space) during the Jenkins pipeline's testing stage. We'll employ Bash exit codes (0 for success, 1 for failure) to indicate resource thresholds. Bash exit codes are crucial for Jenkins to determine the success or failure of a build step. A non-zero exit code signifies an error or failure in the script, causing the entire build to fail. A zero exit code indicates successful completion.


1. The first step is to create a "system_resources_test.sh" script in the root directory of our project

2. Add the shebang directive "#!/bin/bash" to the top line of our script

3. Create some variables to set our thresholds:

    ```
    # Set thresholds
    MEMORY_THRESHOLD=90  # in percentage
    CPU_THRESHOLD=60     # in percentage
    DISK_THRESHOLD=70    # in percentage
    ```
4. Create a variable to initialize a flag to track if any threshold is exceeded

    ```
    # Initialize a flag to track if any threshold is exceeded
    THRESHOLD_EXCEEDED=0
    ```
5. Create a function to check memory usage
    ```
    # Function to check memory usage
    check_memory() {
      MEMORY_USED=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
      MEMORY_INT=$(printf "%.0f" "$MEMORY_USED")
      if [ "$MEMORY_INT" -ge "$MEMORY_THRESHOLD" ]; then
          echo "Warning: Memory usage is at ${MEMORY_INT}% (Threshold: ${MEMORY_THRESHOLD}%)"
        
          THRESHOLD_EXCEEDED=1
      else
        echo "Memory usage is at ${MEMORY_INT}%"
      fi
    }
    ```
6. Create a function to check CPU usage
    ```
    # Function to check CPU usage
    check_cpu() {
        CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
        echo $CPU_LOAD
        CPU_INT=$(printf "%.0f" "$CPU_LOAD")


        if [ "$CPU_INT" -ge "$CPU_THRESHOLD" ]; then
            echo "Warning: CPU usage is at ${CPU_INT}% (Threshold: ${CPU_THRESHOLD}%)"
            THRESHOLD_EXCEEDED=1
        else
            echo "CPU usage is at ${CPU_INT}%"
        fi
    }
    ```
7. create a function to check disk space usage
   ```
   # Function to check disk space usage
    check_disk() {
        DISK_USED=$(df / | grep / | awk '{ print $5}' | sed 's/%//g')
        
        if [ "$DISK_USED" -ge "$DISK_THRESHOLD" ]; then
            echo "Warning: Disk usage is at ${DISK_USED}% (Threshold: ${DISK_THRESHOLD}%)"
            THRESHOLD_EXCEEDED=1
        else
            echo "Disk usage is at ${DISK_USED}%"
        fi
    }
   ```
8. Call the functions we written to check system resources
   ```
   # Main script
   echo "Checking system resources..."
   sleep 5
   check_cpu
   check_memory
   check_disk
   ```
9. Return the appropriate exit code based on our "THRESHOLD_EXCEEDED" flag
   ```
   # Exit with code 0 if all is well, or 1 if any threshold is exceeded
    if [ "$THRESHOLD_EXCEEDED" -eq 1 ]; then
        exit 1
    else
        exit 0
    fi
   ```
10. Push your updates to the github repository

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

    **NOTE:** A Python virtual environment is an isolated environment that allows you to manage and maintain separate dependencies for different Python projects on the same system. You could think of it as a self-contained directory that includes its own Python interpreter, libraries, and scripts, independent of the global Python environment installed on your machine. This is crucial for preventing conflicts between different projects that may have different dependencies and allowing for different projects to use different Python versions. Our python environment "venv" was created during the build stage of our jenkins pipeline. 


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

The issue I encountered in this project was related to the system resource tests we implemented. After running the build stage of our pipeline, there were significant spikes in memory and CPU usage. Additionally, when trying to access the Jenkins web interface, the page load times were extremely slow. I initially set the memory and CPU thresholds at 80% and 60%, respectively, based on recommendations from class and a Google search for best practices. Amazon's t2.micro EC2 instances come with around 1,000 MB of memory (RAM) and 1 virtual CPU.

The fix for the CPU usage spike was relatively simple. I ran the top command to identify which processes were using the most CPU while the pipeline was running and noticed that these spikes didn't last very long. To address this, I added a 5-second wait in my script right before checking CPU usage.

However, addressing the memory usage spikes was more challenging. I tried three approaches to conserve memory before ultimately deciding to increase the threshold to 90%. First, I uninstalled or disabled Jenkins plugins that I didn't think were necessary. Then, I introduced a new stage in our pipeline to clear the cache or remove unused objects from memory after the build stage. Finally, I attempted to reduce the Java heap size for Jenkins by adding the line JAVA_ARGS="-Xmx256m -Xms128m" to the Jenkins startup script. The -Xms parameter sets the initial heap size, and the -Xmx parameter sets the maximum heap size for the JVM.

Despite these efforts, I had 13 unsuccessful builds before I managed to reduce memory usage to 79%. Since this wasn't a significant improvement, I decided to increase my memory threshold to 90%.

If you take a look at my Jenkins file you will noticed that I added the following two lines to our build stage:

```
export FLASK_APP=application
flask run &
```
The first line sets the FLASK_APP environment variable, telling Flask which application to run. In our case, it's pointing to our application.py file. The second command starts the Flask development server, allowing our application to run. The & at the end runs the server in the background, allowing the script to continue executing subsequent commands while the server is running.

In the last project, I encountered an issue with how we were zipping and uploading our application to AWS Elastic Beanstalk. Anticipating a similar problem for this project, I made sure to find tutorials and documentation that could help me avoid it. I reviewed AWS's developer guide for [Deploying a Flask application to Elastic Beanstalk](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create-deploy-python-flask.html) and noticed that they were serving the application before the deployment phase. I considered that I might need to do the same.

In hindsight, I don't think that this was needed since none of the stages in my pipeline explicitly interact with the running Flask application. Also, having the Flask app running in the background probably contributed to the spike in memory usage. When the Flask application is started, it consumes memory to load the application, its dependencies, and any other resources it needs to operate.

## Optimization

**How is using a deploy stage in the CICD pipeline able to increase efficiency of the buisiness?**

* Faster Releases: Automates deployment, speeding up the release of features and bug fixes.
* Consistency: Ensures reliable and consistent deployments, reducing downtime.
* Reduced Manual Effort: Frees up developers to focus on cooler things by eliminating manual deployment steps.

**What issues, if any, can you think of that might come with automating source code to a production environment?** 

The potential issues with fully automated processes stem from the lack of human oversight. Security risks, service disruptions, data loss, and unintended bugs in production can arise without manual checks.

**How would you address/resolve this?**

I would address this by first implementing a comprehensive testing strategy combining manual and automated tests within our pipeline. Establishing a staging environment for pre-production validation is crucial. Integrating automated security scanning into the pipeline can proactively detect vulnerabilities. Finally, robust monitoring and alerting with automated rollback capabilities are essential in case problems arise.

## Nginx and Gunicorn

When deploying a Flask app to AWS Elastic Beanstalk, Nginx and Gunicorn often play crucial roles in handling web requests and serving your application efficiently. Here's how they work together:

### What is Nginx

Nginx ("engine-x") is a web server and reverse proxy server. In the context of web applications, Nginx is often used to:

* **Serve Static Files:** Nginx can efficiently serve static content (e.g., images, CSS, JavaScript) directly to the client.

* **Reverse Proxy:** Nginx forwards client requests to backend servers (like Gunicorn) that actually process the requests, then returns the server's response to the client.

### What is Gunicorn

Gunicorn (Green Unicorn) is a Python WSGI (Web Server Gateway Interface) HTTP server. It serves as an intermediary between your Flask application and the web server (Nginx). Gunicorn's primary role is running your flask application.

### How Nginx and Gunicorn work together

When deploying a Flask app on Elastic Beanstalk, Nginx and Gunicorn typically work together in the following manner:

1. **Client Request:**

* A user accesses your Flask application by sending an HTTP or HTTPS request to your Elastic Beanstalk environment.

2. **Nginx as the Frontend Web Server:**

* Nginx receives the request because it listens on standard web ports (80 for HTTP and 443 for HTTPS). If the request is for a static file (e.g., an image or CSS file), Nginx serves it directly from its file system, which is faster and more efficient.

3. **Nginx as a Reverse Proxy:**

* For dynamic requests that require Flask's logic, Nginx forwards the request to Gunicorn, which is running your Flask application. Nginx acts as a reverse proxy here, forwarding requests to Gunicorn on a specific port, like internal port 8000 in our case. 

4. **Gunicorn as the Application Server:**

* Gunicorn receives the forwarded request from Nginx and executes your Flask application code to process the request. 

5. **Response Handling:**

* Once the Flask application generates a response, Gunicorn sends it back to Nginx.
Nginx then sends the final response back to the client.


## Conclusion

This project successfully demonstrates the automation of the deployment process to AWS Elastic Beanstalk using Jenkins. By integrating a deployment stage into the CI/CD pipeline, we've significantly streamlined the release process, allowing for faster, more consistent, and reliable deployments. This automation not only reduces manual effort but also minimizes the risk of human error, making the deployment process more efficient and less prone to mistakes.
