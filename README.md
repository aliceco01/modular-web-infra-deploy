
# Automated Deployment Framework for Scalable Two-Tier Web Architectures

This web application allows you to search download to your personal device any movie poster you like.

# Technologies Used 

 - Amazon Web Services 
 - Python Flask 
 - MongoDB 
 - Terraform HashiCorp
 - Docker


![image](https://user-images.githubusercontent.com/83873276/178243696-faa26d74-aefb-41a8-afbc-3dfcaa168431.png)

# Prerequisites to make it work

1) TMDB API key - open an account at this link https://www.themoviedb.org/signup
2) navigate to [https://www.themoviedb.org/settings/api](https://www.themoviedb.org/settings/api) 



3) generate an API Key
4) ![image](https://user-images.githubusercontent.com/82024584/175267304-7561208b-8804-4ed8-a82e-2dba984a0f25.png)
5) make a new file in the same folder as the project and name it config.py and put inside the api key and save.
6) ![image](https://user-images.githubusercontent.com/82024584/175267611-861f98bf-074a-4e35-82f5-4698d408adb9.png)
7) Use Access keys in terraform to bring the infrastructure up in 1-click, put them in main.tf

![image](https://user-images.githubusercontent.com/82024584/175268336-9338577a-f160-491c-bf57-e980515b5f6f.png)

8) At this point all is left to do is to run the commands - terraform init, terraform plan, terraform apply. 
9) When done, use terraform destroy.





# Flow Chart:

![ProjectFlowChart](https://user-images.githubusercontent.com/82024584/168774364-a427dfd5-a9c2-4581-9c18-71531f6dbb0b.PNG)
