

# movie posters

Project web app 

The Project is a Web App.

The Web App gives the users the option to search posters and having the option to download them.

The Web App asks the user for a movie to search, after taking the input from the user the app displays all the movie names similar to what the user searched and their corresponding poster images.

Then the user gets the choice to select posters he wants to download. we used git as our version control and github as our repository manager.

For the frontend UI we used HTML and our framework was python flask library. We chose it instead of Django because it was  lightweight and uses dry core, even though it’s not as scalable – and also we could different databases. Python Flask Library  also providied the routing (mapping the URLs to a specific function that will handle the logic of that URL) and to create API for a the movie website.

To get the image of the movie posters, we used a public API by creating an account on TMDB (which is a large movie database that had all the images) and then requested an API key.

To store all the movie posters,  in a form on a non-relational data base we used MongoDB as the local BackEnd Database. so when the user is searching for a poster, the local database in the web app front end is looking for it.  If poster exists in local DB meaning  if the query to the database is true then we output a command that displays the poster to the user.

If it’s false and it’s not in the database then via the api call we download the poster from TMBD into the local database  we expected a challenge with saving big binary files to store on mongo, so we used a DBMS called GridFS which is a filesystem to store files and the data is stored in Mongo collections. Also we used PyMongo which is a package that contains tools for interacting with MongoDB from python.

We dockerized our mongo databases – the way we did it is creating a userdata file text file that will install docker, will fatch the latests version from git and will create the images and load the containers.

AWS is the cloud provider where the Web App is hosted on  a vpc an EC2 instance and load balancers.

Docker Containers were used on EC2 to isolate the frontend and backend apps.

Terraform was used to initialize and bring the entire architecture up in AWS Cloud, And what allowed the  automation and  the  provisioning of infrastructure.

So overall on our vpc we had 2 public subnets on which we had the nat gateways ( which is what allowing connection to aws resources and network)

And 2 private subnets that have HTTP access through security groups on the private subnets we had an EC2 web instance

And on the ec2 we used docker containers, to isolate frontend backend and dependencies and allow for scailing and automation with terraform.


![image](https://user-images.githubusercontent.com/83873276/177345745-aa651940-a84c-4e2c-a7e5-cd0d24452c50.png)

